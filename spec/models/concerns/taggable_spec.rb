describe Taggable do
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define do
      create_table :taggable_classes, force: true do |t|
        t.jsonb 'tags'
      end

      create_table :other_taggable_classes, force: true do |t|
        t.jsonb 'tags'
      end
    end
  end

  let!(:registered_before_includes) { Taggable.registered.dup }

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
      TaggableClass.create(tags: 'a')
      expect(TaggableClass.tagged_with_any('a', 'b')).to eq TaggableClass.tagged_with_any(['a', 'b'])
    end

    it 'does not find unmatched' do
      TaggableClass.create
      expect(TaggableClass.tagged_with_any('a', 'b')).to be_empty
    end
  end

  describe 'TaggableClass' do
    describe '.tagged_with_all' do
      it "finds exact matches" do
        TaggableClass.create
        tagged_item = TaggableClass.create(tags: ['a', 'b'])

        expect(TaggableClass.tagged_with('a', 'b')).to contain_exactly(tagged_item)
      end

      it "works with array and arg splat" do
        TaggableClass.create(tags: ['a', 'b'])
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

        expect(TaggableClass.all_tags.size).to eq 3
      end
    end

    describe 'remove_tag_from' do

    end

    describe 'add_tag' do
      let!(:t1) { TaggableClass.create(tags: "a,b") }

      it 'does not add duplicate tag' do
        TaggableClass.add_tag('c')

        expect(t1.reload.tags).to include('a', 'b', 'c')
      end

      context "with many tagged instances" do
        let!(:t2) { TaggableClass.create(tags: "1,2") }

        it 'adds to all by default' do
          TaggableClass.add_tag('c')

          expect(t1.reload).to include 'c'
          expect(t2.reload).to include 'c'
        end

        it 'only adds to selected records' do
          TaggableClass.add_tag('c', [t1.id])

          expect(t1.reload).to include 'c'
          expect(t2.reload).to_not include 'c'
        end
      end
    end
  end

  describe '.registered' do
    it 'is a list of taggable classes' do
      expect(Taggable.registered).to include(TaggableClass)
    end
  end

  describe '.tags_by_class' do
    class OtherTaggableClass < ActiveRecord::Base
      include Taggable
    end

    let(:tags_by_class) { Taggable.tags_by_class }

    it 'groups tags by the model name' do
      TaggableClass.create(tags: "a,b")
      OtherTaggableClass.create(tags: "a,c")

      expect(tags_by_class['TaggableClass'] = ['a', 'b'])
      expect(tags_by_class['OtherTaggableClass'] = ['b', 'c'])
    end
  end
end
