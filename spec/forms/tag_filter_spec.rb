# frozen_string_literal: true

describe TagFilter do
  let(:tag_filter) { TagFilter.new({}) }

  describe 'defaults' do
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
  end
end
