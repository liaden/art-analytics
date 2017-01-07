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
      expect(query_results[e.reload.full_name]).to eq value
    end
  end

  def daily_results_on(event, results = query_results)
    daily_results(results, event)
  end

  def daily_results(results, event)
    event.reload # refresh for full_name

    result = {}

    # key is [event.full_name, :day_of_week]
    results.each do |key, value|
      if key.first == event.full_name
        result[key.last] = value
      end
    end
    result
  end

  describe 'event filter'
  describe 'merchandise filter'
  describe 'artwork filter'

  context 'unfiltered' do
    describe '#total_revenue' do
      before { no_sales_per_day.transform_values! { |_x| "0.0" } }
      let(:query_results) { query.total_revenue }

      it 'computes revenue across two sales' do
        e = create(:event, :with_sale, :with_huge_price)
        expect(e.sales.size).to eq 2
        expect(e.sales.map(&:sale_price).reduce(:+).dollars.to_s).to eq query_results.values.first
      end

      it 'includes all events' do
        e1 = create(:event, :with_sale)
        e2 = create(:event, :with_huge_price)

        result_matches_exactly(e1 => "25.0", e2 =>"12345.0")
      end

      it 'adds multiple sales at event' do
        e = create(:event, :with_sale, :with_sale_of_many)
        result_matches_exactly(e => "50.0")
      end

      it 'handles event without sales' do
        create(:event)
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
        create(:event)
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
        create(:event)
        expect(query_results).to be_empty
      end
    end

    describe '#revenue_per_day' do
      let(:query_results) { query.revenue_per_day }
      before { no_sales_per_day.transform_values! { |_x| "0.0" } }

      it 'handles simple case' do
        e = create(:event, :with_sale)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: "25.0"))
      end

      it 'handles multiple sales in a day' do
        e = create(:event, :with_sale)
        create(:sale, :with_merchandise, event: e, sale_price: 50)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: "75.0"))
      end

      it 'handles sales over different days' do
        e = create(:event, :with_sale)
        create(:sale, :with_merchandise, sold_on: Date.today.friday+1.day, event: e, sale_price: 50)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: "25.0", sat: "50.0"))
      end

      it 'handles sale of multiple merchandise' do
        e = create(:event, :with_complex_sales)

        expect(daily_results_on(e)).to eq(no_sales_per_day.merge(fri: "80.0", sat: "25.0"))
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

  describe '#run' do
    it 'does not run invalid method' do
      expect(query).to_not receive(:send)

      expect(query.run(:not, :real)).to be_empty
    end

    it 'runs per_day grouping' do
      expect(query).to receive(:sold_items_per_day)
      query.run(:per_day, :sold_items)
    end

    it 'runs total grouping' do
      expect(query).to receive(:total_sold_items)
      query.run(:total, :sold_items)
    end
  end
end
