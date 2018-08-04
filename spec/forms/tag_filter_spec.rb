describe TagFilter do
  context 'with defaults' do
    let(:tag_filter) { TagFilter.new(tag_filter_params) }
    let(:tag_filter_params) { Hash.new }

    it 'is valid' do
      expect(tag_filter).to be_valid
    end

    it 'has empty tags' do
      expect(tag_filter.tags).to be_empty
    end

    it 'defaults matching all tags' do
      expect(tag_filter.matching_mechanism).to eq 'all'
    end

    it 'prepends nothing' do
      expect(tag_filter.prepend_with).to be_nil
    end

    it 'generates empty sql' do
      expect(tag_filter.to_sql).to be_empty
    end
  end

  describe '#to_sql' do
    let(:prepend_with) { nil }
    let(:on) { 'name' }
    let(:matching_mechanism) { 'all' }
    let(:tags) { ['x'] }

    let(:tag_filter) { TagFilter.new(on: on, matching_mechanism: matching_mechanism, tags: tags, prepend_with: prepend_with) }

    context 'without prepend_with' do
      it 'starts with quoted name' do
        expect(tag_filter.to_sql).to start_with('"name".')
      end
    end

    context 'prepend_with is set' do
      let(:prepend_with) { 'and' }

      it 'starts with chosen option' do
        expect(tag_filter.to_sql).to start_with('AND (')
        expect(tag_filter.to_sql).to end_with(')')
      end
    end
  end
end
