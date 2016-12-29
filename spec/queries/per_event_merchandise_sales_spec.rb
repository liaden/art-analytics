require 'rails_helper'

describe PerEventMerchandiseSales do
  let(:query) { PerEventMerchandiseSales.new(event_tag_filter: event_filter, merchandise_tag_filter: merchandise_filter, artwork_tag_filter: artwork_filter) }

  let(:artwork_filter) { nil }
  let(:merchandise_filter) { nil }
  let(:event_filter) { nil }
  let(:no_sales_per_day) { {mon: 0, tues: 0, wed: 0, thurs: 0, fri: 0, sat: 0, sun: 0} }

  def result_matches_exactly(events_to_values)
    expect(events_to_values.size).to eq query_results.keys.size

    events_to_values.each do |e,value|
      expect(query_results[[e.id, e.name]]).to_not be_nil
      expect(query_results[[e.id, e.name]]).to eq value
    end
  end

  def daily_results_on(event, results = query_results)
    daily_results(results, event)
  end

  def daily_results(results, event)
    days = [:mon, :tues, :wed, :thurs, :fri, :sat, :sun ]
    result = {}
    #
    # key is [event.id, event.name, indexed_day_of_week]
    results.each do |key, value|
      if key[0] == event.id
        day = days[key[2]]
        result[day] = value
      end
    end
    result
  end

  describe 'event filter'
  describe 'merchandise filter'
  describe 'artwork filter'

  context 'unfiltered' do
    describe '#total_revenue' do
      let(:query_results) { query.total_revenue }

      it 'computes revenue across two sales' do
        e = create(:event, :with_sale, :with_huge_price).reload
        expect(e.sales.size).to eq 2
        expect(e.sales.map(&:sale_price).reduce(:+)).to eq query_results.values.first
      end

      it 'includes all events' do
        e1 = create(:event, :with_sale)
        e2 = create(:event, :with_huge_price)

        result_matches_exactly(e1 => 2500, e2 =>123456789)
      end

      it 'adds multiple sales at event' do
        e = create(:event, :with_sale, :with_sale_of_many)
        result_matches_exactly(e => 5000)
      end

      it 'handles event without sales' do
        e = create(:event)
        expect(query_results).to be_empty
      end
    end

    describe '#total_sold_items' do
      let(:query_results) { query.total_sold_items }

      it 'includes all events' do
        e1 = create(:event, :with_sale, :with_sale_of_many)
        e2 = create(:event, :with_complex_sales)

        result_matches_exactly(e1 => 4, e2 => 7)
      end

      it 'handles event without sales' do
        e = create(:event)
        expect(query_results).to be_empty
      end
    end

    describe '#total_customers' do
      let(:query_results) { query.total_customers }

      it 'includes all events' do
        e1 = create(:event, :with_sale, :with_sale_of_many)
        e2 = create(:event, :with_complex_sales)

        result_matches_exactly(e1 => 2, e2 => 5)
      end

      it 'handles event without custoemrs' do
        e = create(:event)
        expect(query_results).to be_empty
      end
    end

    describe '#revenue_per_day' do
      let(:query_results) { query.revenue_per_day }

      it 'handles simple case' do
        e = create(:event, :with_sale)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: 2500))
      end

      it 'handles multiple sales in a day' do
        e = create(:event, :with_sale)
        create(:sale, :with_merchandise, event: e, sale_price: 5000)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: 7500))
      end

      it 'handles sales over different days' do
        e = create(:event, :with_sale)
        create(:sale, :with_merchandise, sold_on: Date.today.friday+1.day, event: e, sale_price: 5000)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: 2500, sat: 5000))
      end
    end

    describe '#sold_items_per_day' do
      let(:query_results) { query.sold_items_per_day }

      it 'computes simple case' do
        e = create(:event, :with_sale)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: 1))
      end

      it 'handles multiple sales in an event' do
        e = create(:event, :with_sale)
        create(:sale, :with_merchandise, event: e)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: 2))
      end

      it 'handles multiple items sold at once' do
        e = create(:event, :with_sale_of_many)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: 3))
      end

      it 'handles multiple of the same item sold at once' do
        e = create(:event, :with_sale)
        create(:sale, event: e, of_merchandise: Merchandise.last, quantity: 2)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: 3))
      end

      it 'separates sales over days' do
        e = create(:event, :with_sale)
        create(:sale, :with_merchandise, event: e, sold_on: Date.today.friday + 1.day)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: 1, sat: 1))
      end
    end

    describe '#customers_per_day' do
      let(:query_results) { query.customers_per_day }

      it 'computes simple case' do
        e = create(:event, :with_sale)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: 1))
      end

      it 'handles monday following the weekend is part of the event' do
        e = create(:event, :with_sale, ended_at: Date.today.friday+3.days)
        create(:sale, event: e, sold_on: Date.today.friday+3.days)

        expect(query_results.size).to eq 7
        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(mon: 1, fri: 1))
      end

      it 'works works with multiple events' do
        e1 = create(:event, :with_sale)
        e2 = create(:event, :with_complex_sales)

        expect(daily_results_on(e1)).to eq(no_sales_per_day.merge(fri: 1))
        expect(daily_results_on(e2)).to eq(no_sales_per_day.merge(fri: 4, sat: 1))
      end
    end
  end
end
