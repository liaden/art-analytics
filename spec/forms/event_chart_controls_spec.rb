require 'rails_helper'

describe EventChartControls do
  let(:controls) { build(:event_chart_controls, chart_params) }
  let(:chart_params) { { grouping: 'total' } }

  describe 'validations' do
    it 'is valid' do
      expect(controls).to be_valid
    end

    context 'fails when' do
      after { expect(controls).to be_invalid }

      it('has unknown grouping') { controls.grouping = 'abcd' }
      it('has unknown ordering') { controls.ordering = 'abbd' }
      it('has unknown metric')   { controls.metric   = 'abcd' }
    end

    context 'ignores ordering validation when' do
      let(:chart_params) { { ordering: 'abcd' } }

      it 'has per_day grouping' do
        controls.grouping = 'per_day'
        expect(controls).to be_valid
      end
    end
  end

  describe '#within_date' do
    subject { controls.within_date }

    let(:chart_params) { { date_after: 1.year.ago, date_before: Date.today } }

    it { is_expected.to_not be_none }
  end
end
