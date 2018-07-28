describe ArtworkPairings do
  describe '#run' do
    let(:artwork_pairing_config) { Hash.new }
    let(:artwork_pairings) { ArtworkPairings.new(artwork_pairing_config) }

    let(:result) { artwork_pairings.run }
    let(:tags) { 'tag1,tag2,tag3' }

    let(:merch1) { create(:merchandise, artwork: artwork1, tags: 'm1,m2,m3') }
    let(:merch2) { create(:merchandise, artwork: artwork2, tags: 'm4,m5,m6') }
    let(:artwork1) { create(:artwork, tags: 'a,b,c') }
    let(:artwork2) { create(:artwork, tags: 'x,y,z') }

    context 'no filters' do
      it 'does not show solitary sales' do
        create(:sale, :with_event, of_merchandise: merch1)
        expect(result).to be_empty
      end

      pending 'shows pairing with self when bought with self' do
        create(:sale, :with_event, of_merchandise: merch1, quantity: 2)

        expected = [ { 'root_name' => artwork1.name, 'associated_artwork_name' => artwork1.name, 'paired_frequency' => 1 } ]
        expect(result).to eq expected
      end

      it 'includes both directions' do
        create(:sale, :with_event, :with_merchandise, number_of_merch: 2)

        expect(result.size).to eq 2
        expect(result.first['root_name']).to eq result.second['associated_artwork_name']
        expect(result.first['associated_artwork_name']).to eq result.second['root_name']
        expect(result.first['paired_frequency']).to eq result.second['paired_frequency']
      end

      it 'works across events' do
        create(:sale, :with_event, :with_merchandise, number_of_merch: 2)
        create(:sale, :with_event, :with_merchandise, number_of_merch: 2)

        expect(result.size).to eq 4
        expect(result.uniq.size).to eq 4
      end
    end

    context 'filtering root artwork tags' do
      def merge_art_tag_filter(name, attrs)
        artwork_pairing_config.merge!("artwork_tag_filter_#{name}".to_sym => attrs)
      end

      let!(:matching_sale) { create(:sale, merchandises: [merch1, merch2]) }

      context 'matching all' do
        before { merge_art_tag_filter(:a_root, attributes_for(:tag_filter, :matches_all, tags: ['x'])) }

        it 'only shows one direction' do
          expect(result).to eq [{'root_name' => artwork2.name, 'associated_artwork_name' => artwork1.name, 'paired_frequency' => 1}]
        end

        it 'is empty when root does not match' do
          artwork2.update(tags: 'y,z')
          expect(result).to be_empty
        end

        it 'matches and counts all sales' do
          create(:sale, merchandises: [merch1, merch2])
          expect(result.size).to eq 1
          expect(result.first['paired_frequency']).to eq 2
        end

        context 'with other artwork filter' do
          before { merge_art_tag_filter(:a_other, attributes_for(:tag_filter, :matches_all, tags: ['a'])) }

          it 'monly shows one direction while matching both sides' do
            expect(result).to eq [{ 'root_name' => artwork2.name, 'associated_artwork_name' => artwork1.name, 'paired_frequency' => 1 }]
          end

          it 'is empty when associated does not match' do
            artwork1.update(tags: 'b,c')
            expect(result).to be_empty
          end
        end

        context 'with several tags' do
          before { merge_art_tag_filter(:a_root, attributes_for(:tag_filter, :matches_all, tags: ['x','y'])) }

          it 'shows one direction' do
            expect(result).to eq [{'root_name' => artwork2.name, 'associated_artwork_name' => artwork1.name, 'paired_frequency' => 1}]
          end
        end
      end

      context 'matching some' do
        before { merge_art_tag_filter(:a_other, attributes_for(:tag_filter, :matches_some, tags: ['a','x'])) }

        let!(:matching_sale) { create(:sale, merchandises: [merch1, merch2]) }

        it 'shows both directions' do
          expect(result.size).to eq 2
          expect(result).to include(
            { 'root_name' => artwork1.name, 'associated_artwork_name' => artwork2.name, 'paired_frequency' => 1 },
            { 'root_name' => artwork2.name, 'associated_artwork_name' => artwork1.name, 'paired_frequency' => 1 }
          )
        end
      end
    end

    context 'filtering merchandise tags' do
    end

    context 'filtering event tags' do
    end

    context 'filtering time periods 'do
    end

    context 'having minimum pairing frequency' do
    end
  end
end
