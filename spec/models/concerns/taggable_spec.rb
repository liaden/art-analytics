# frozen_string_literal: true

describe Taggable do
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define do
      create_table :taggable_classes, force: true do |t|
        t.jsonb 'tags'
      end
    end
  end

  class TaggableClass < ActiveRecord::Base
    include Taggable
  end

  let(:taggable_item) { TaggableClass.new }

  describe '#tags=' do
    it 'assigns array' do
      taggable_item.tags = ['a', 'b']
      expect(taggable_item.tags).to contain_exactly('a', 'b')
    end

    it 'parses csv tags' do
      taggable_item.tags = "a,b"
      expect(taggable_item.tags).to contain_exactly('a', 'b')
    end

    it 'assigns singular item' do
      taggable_item.tags = "a"
      expect(taggable_item.tags).to contain_exactly('a')
    end

    it 'overwrites previous tags' do
      taggable_item.tags = ['x']
      taggable_item.tags = ["a", "b"]

      expect(taggable_item.tags).to contain_exactly('a','b')
    end
  end

  describe '#tags' do
    it 'returns [] when column is nil' do
      expect(TaggableClass.new.tags).to be_empty
    end

    it 'allows appending to tags' do
      taggable_item.tags = 'x'
      taggable_item.tags << 'a'

      expect(taggable_item.tags).to contain_exactly('x', 'a')
    end
  end

  describe '.tagged_with_any' do
    it 'finds partial match' do
      tagged_item = TaggableClass.create(tags: 'a')
      expect(TaggableClass.tagged_with_any('a', 'b')).to contain_exactly(tagged_item)
    end

    it 'works with array and arg splat' do
      tagged_item = TaggableClass.create(tags: 'a')
      expect(TaggableClass.tagged_with_any('a', 'b')).to eq TaggableClass.tagged_with_any(['a', 'b'])
    end

    it 'does not find unmatched' do
      TaggableClass.create
      expect(TaggableClass.tagged_with_any('a', 'b')).to be_empty
    end
  end

  describe '.tagged_with_all' do
    it "finds exact matches" do
      TaggableClass.create
      tagged_item = TaggableClass.create(tags: ['a', 'b'])

      expect(TaggableClass.tagged_with('a', 'b')).to contain_exactly(tagged_item)
    end

    it "works with array and arg splat" do
      tagged_item = TaggableClass.create(tags: ['a', 'b'])
      expect(TaggableClass.tagged_with('a', 'b')).to eq TaggableClass.tagged_with(['a', 'b'])
    end

    it "does not find partial match" do
      TaggableClass.create(tags: 'a')
      expect(TaggableClass.tagged_with('a', 'b')).to be_empty
    end
  end

  describe '.untagged' do
    it "includes records with tags ==  nil" do
      item = TaggableClass.create(tags: nil)
      expect(TaggableClass.untagged).to eq [item]
    end

    it "includes record with tags == []" do
      item = TaggableClass.create(tags: [])
      expect(TaggableClass.untagged).to eq [item]
    end
  end

  describe '.all_tags' do
    it "returns unique tags" do
      TaggableClass.create(tags: "a,b")
      TaggableClass.create(tags: "b,c")
      TaggableClass.create(tags: "b,c")

      expect(TaggableClass.all_tags).to include('a', 'b', 'c')
    end

    it 'handles no TaggableClass instances' do
      expect(TaggableClass.all_tags).to be_empty
    end
  end

  describe '.tags_with_prefix' do
    it 'handles no tagged items existing' do
      expect(TaggableClass.tags_with_prefix('has no match')).to be_empty
    end

    context 'with tagged rows' do
      before do
        TaggableClass.create(tags: '5 stars,tasty,fast')
        TaggableClass.create(tags: '4 stars,tasty,bad service')
        TaggableClass.create(tags: '1 stars,bad')
      end

      it 'matches number prefix' do
        expect(TaggableClass.tags_with_prefix('5')).to include('5 stars')
      end

      it 'matches prefix as whole tag' do
        expect(TaggableClass.tags_with_prefix('bad')).to include('bad', 'bad service')
      end

      it 'with no matches, it is empty' do
        expect(TaggableClass.tags_with_prefix('has no match')).to be_empty
      end
    end
  end
end
