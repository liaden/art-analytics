# frozen_string_literal: true

describe Taggable do
  before(:all) do
    Taggable.instance_variable_set(:@resource_names, nil)
  end

  before(:all) do
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Schema.define do
        create_table :taggable_classes, force: true do |t|
          t.jsonb 'tags'
          t.datetime 'created_at'
          t.datetime 'updated_at'
        end

        create_table :default_taggables, force: true do |t|
          t.jsonb 'tags', default: [], null: false
          t.datetime 'created_at'
          t.datetime 'updated_at'
        end
      end
    end

    class TaggableClass < ActiveRecord::Base
      include Taggable
    end

    class DefaultTaggable < ActiveRecord::Base
      include Taggable
    end
  end

  after(:all) do
    Taggable.instance_variable_set(:@resource_names, nil)
    Object.send(:remove_const, :TaggableClass)
    Object.send(:remove_const, :DefaultTaggable)
  end

  let(:taggable_item)    { TaggableClass.new }
  let(:default_taggable) { DefaultTaggable.new }

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

    it 'strips whitespace' do
      taggable_item.tags = 'x ,y '
      expect(taggable_item.tags).to contain_exactly('x','y')
    end

    it 'enforces uniqueness' do
      taggable_item.tags = 'x ,x'
      expect(taggable_item.tags).to eq ['x']
    end
  end

  describe '#tags' do
    describe 'with default value in the schema' do
      it 'returns [] when column is nil' do
        expect(default_taggable.tags).to be_empty
      end

      it 'allows appending to tags' do
        default_taggable.tags << 'x'
        default_taggable.tags << 'a'
        default_taggable.save!

        expect(default_taggable.reload.tags).to contain_exactly('x', 'a')
      end
    end

    context 'without a default value' do
      it 'returns nil' do
        expect(taggable_item.tags).to eq(nil)
      end
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

    describe 'atypical arguments' do
      let(:untagged) { TaggableClass.create }
      let(:tagged)   { TaggableClass.create(tags: 'a') }

      it "handles nil as input" do
        expect(TaggableClass.tagged_with_any(nil)).to include(untagged, tagged)
      end

      it "handles no arguments" do
        expect(TaggableClass.tagged_with_any()).to include(untagged, tagged)
      end
    end
  end

  describe '.tagged_with' do
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

    describe 'atypical arguments' do
      let(:untagged) { TaggableClass.create }
      let(:tagged)   { TaggableClass.create(tags: 'a') }

      it "handles nil as input" do
        expect(TaggableClass.tagged_with(nil)).to include(untagged, tagged)
      end

      it "handles no arguments" do
        expect(TaggableClass.tagged_with()).to include(untagged, tagged)
      end
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

  describe '.delete_tags' do
    let!(:item) { TaggableClass.create(tags: ['a', 'b', 'c']) }

    it 'removes a tag' do
      TaggableClass.delete_tags('a')
      expect(item.reload.tags).to eq(['b', 'c'])
    end

    it 'handles nil' do
      untagged = TaggableClass.create()
      TaggableClass.delete_tags('a')
      expect(item.reload.tags).to eq(['b', 'c'])
      expect(untagged.reload.tags).to be_nil
    end

    it 'removes several tags' do
      TaggableClass.delete_tags('a', 'b')
      expect(item.reload.tags).to eq(['c'])
    end

    it 'removes several but one is missing' do
      TaggableClass.delete_tags('a', 'd')
      expect(item.reload.tags).to eq(['b', 'c'])
    end

    it 'updated multiple records' do
      item2 = TaggableClass.create(tags: ['a', 'b', 'c'])
      TaggableClass.delete_tags('a', 'b')

      expect(item.reload.tags).to eq(['c'])
      expect(item2.reload.tags).to eq(['c'])
    end

    it 'updates updated_at' do
      TaggableClass.delete_tags('a')
      expect(item.updated_at).to be < item.reload.updated_at
    end

    context 'with additional filtering' do
      let!(:item2) { TaggableClass.create(tags: ['b', 'c']) }

      it 'does not delete the tag' do
        TaggableClass.tagged_with('a').delete_tags('a', 'b')
        expect(item.reload.tags).to eq(['c'])
        expect(item2.reload.tags).to eq(['b', 'c'])
      end
    end

    context 'nothing to delete' do
      it 'keeps the same tags' do
        TaggableClass.delete_tags('d')
        expect(item.reload.tags).to eq(['a', 'b', 'c'])
      end

      it 'does not change updated_at' do
        expect {
          TaggableClass.delete_tags('d')
        }.to_not change { item.reload.updated_at }
      end
    end

    context 'uncommon arguments' do
      it 'array of arrays' do
        TaggableClass.delete_tags(['a', 'b'])
        expect(item.reload.tags).to eq(['c'])
      end

      it 'ignores nil' do
        TaggableClass.delete_tags('a', 'b', nil)
        expect(item.reload.tags).to eq(['c'])
      end

      it 'strips whitespace from tags' do
        TaggableClass.delete_tags(' a', 'b ')
        expect(item.reload.tags).to eq(['c'])
      end

      it 'does nothing on empty array' do
        expect {
          TaggableClass.delete_tags()
        }.to_not change { item.reload }
      end
    end
  end

  describe '.insert_tags' do
    let!(:item) { DefaultTaggable.create(tags: initial_tags) }

    let(:initial_tags) { nil }

    it 'creates a tag' do
      DefaultTaggable.insert_tags('a')
      expect(item.reload.tags).to eq(['a'])
    end

    it 'handles nil' do
      untagged = TaggableClass.create
      TaggableClass.insert_tags('a')
      expect(untagged.reload.tags).to eq(['a'])
    end

    it 'creates many tags' do
      DefaultTaggable.insert_tags('a', 'b')
      expect(item.reload.tags).to eq(['a', 'b'])
    end

    it 'updates updated_at' do
      DefaultTaggable.insert_tags('a')
      expect(item.updated_at).to be < item.reload.updated_at
    end

    it 'adds tags on two items' do
      item2 = DefaultTaggable.create
      DefaultTaggable.insert_tags('a')
      expect(item2.reload.tags).to eq(['a'])
    end

    context 'already has tag' do
      let(:initial_tags) { ['a', 'b'] }

      it 'has same tags' do
        DefaultTaggable.insert_tags('a')
        expect(item.reload.tags).to eq(['a', 'b'])
      end

      it 'does not change updated_at' do
        expect {
          DefaultTaggable.insert_tags('a')
        }.to_not change { item.reload.updated_at }
      end
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

    it 'returns tags in alphabetical order' do
      TaggableClass.create(tags: "b,c")
      TaggableClass.create(tags: "a,b")

      expect(TaggableClass.all_tags).to eq(['a', 'b', 'c'])
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

      it 'is in alphabetical order' do
        TaggableClass.create(tags: 'alpha2,alpha1')
        TaggableClass.create(tags: 'alpha3,alpha2')

        expect(TaggableClass.tags_with_prefix('alph')).to eq(['alpha1', 'alpha2', 'alpha3'])
      end
    end
  end
end
