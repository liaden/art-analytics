# frozen_string_literal: true

describe TagFilterFragment do
  context 'with defaults' do
    let(:tag_filter) { TagFilterFragment.new(TagFilter.new(tag_filter_params)) }
    let(:tag_filter_params) { Hash.new }

    it 'generates empty sql' do
      expect(tag_filter.to_sql).to be_empty
    end
  end

  describe '#to_sql' do
    let(:prepend_with) { nil }
    let(:on) { 'table_name' }
    let(:matching_mechanism) { 'all' }
    let(:tags) { ['x'] }

    let(:tag_filter) do
      TagFilterFragment.new(
        TagFilter.new(on: on, matching_mechanism: matching_mechanism, tags: tags, prepend_with: prepend_with)
      )
    end

    context 'without prepend_with' do
      it 'starts with quoted name' do
        expect(tag_filter.to_sql).to start_with('coalesce("table_name".')
      end
    end

    context 'prepend_with is set' do
      let(:prepend_with) { 'and' }

      it 'starts with chosen option' do
        expect(tag_filter.to_sql).to start_with('AND (')
        expect(tag_filter.to_sql).to end_with(')')
      end

      describe 'with overload specified' do
        it 'uses prepend_with argument' do
          expect(tag_filter.to_sql('OR')).to start_with('OR')
        end
      end
    end
  end
end
