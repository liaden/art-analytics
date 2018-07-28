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

    def expectation(root, associated, num)
      { 'root_name' => root.name, 'associated_artwork_name' => associated.name, 'paired_frequency' => num }
    end

    context 'no filters' do
      it 'does not show solitary sales' do
        create(:sale, :with_event, of_merchandise: merch1)
        expect(result).to be_empty
      end

      it  'shows pairing with self when bought with self' do
        create(:sale, :with_event, of_merchandise: merch1, quantity: 2)

        expect(result).to eq [ expectation(artwork1, artwork1, 1) ]
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

    [
      [ 'artwork', :artwork ],
      [ 'merchandise', :merch ]
    ].each do |model_name, item_var_name |
      describe  "filtering #{model_name} tags" do
        def merge_tag_filter(name, attrs)
          artwork_pairing_config.merge!("#{resource}_tag_filter_#{name}".to_sym => attrs)
        end

        let!(:matching_sale) { create(:sale, merchandises: [merch1, merch2]) }

        # just define a mapping of
        # item1 -> merch1 or artwork1, item2 => merch2 or artwork2
        # we need to cache resource so that merge_tag_filter can access it
        let(:item1) { self.send("#{item_var_name}1") }
        let(:item2) { self.send("#{item_var_name}2") }
        let(:resource) { model_name }
        let(:root_str) { "#{resource.first}_root" }
        let(:other_str) { "#{resource.first}_other" }

        context 'matching all' do
          before { merge_tag_filter(root_str, attributes_for(:tag_filter, :matches_all, tags: [item2.tags.first])) }

          it 'only shows one direction' do
            expect(result).to eq [{'root_name' => artwork2.name, 'associated_artwork_name' => artwork1.name, 'paired_frequency' => 1}]
          end

          it 'is empty when root does not match' do
            # removes the first tag
            item2.update(tags: [item2.tags.second, item2.tags.third] )
            expect(result).to be_empty
          end

          it 'matches and counts all sales' do
            create(:sale, merchandises: [merch1, merch2])
            expect(result.size).to eq 1
            expect(result.first['paired_frequency']).to eq 2
          end

          context "with other #{model_name} filter" do
            before { merge_tag_filter(other_str, attributes_for(:tag_filter, :matches_all, tags: [item1.tags.first])) }

            it 'only shows one direction while matching both sides' do
              expect(result).to eq [{ 'root_name' => artwork2.name, 'associated_artwork_name' => artwork1.name, 'paired_frequency' => 1 }]
            end

            it 'is empty when associated does not match' do
              item1.update(tags: [item1.tags.second, item1.tags.third])
              expect(result).to be_empty
            end
          end

          context 'with several tags' do
            before { merge_tag_filter(root_str, attributes_for(:tag_filter, :matches_all, tags: [item2.tags.first, item2.tags.second])) }

            it 'shows one direction' do
              expect(result).to eq [{'root_name' => artwork2.name, 'associated_artwork_name' => artwork1.name, 'paired_frequency' => 1}]
            end
          end
        end

        context 'matching some' do
          before { merge_tag_filter(other_str, attributes_for(:tag_filter, :matches_some, tags: [item1.tags.first, item2.tags.first])) }

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
    end

    describe  'filtering time periods 'do
      context ' with specific time range' do
        let(:artwork_pairing_config) do
          { earliest_date: Date.today - 2.weeks, latest_date: Date.today - 1.week }
        end
        let(:matching_sale) { create(:sale, event: event, sold_at: event_started_at, merchandises: [merch1, merch2]) }
        let(:event) { create(:event, started_at: event_started_at) }

        let(:subject) { matching_sale; result }

        context 'before the time range' do
          let(:event_started_at) { artwork_pairing_config[:earliest_date] - 1.week }

          it { is_expected.to be_empty }
        end

        context 'after the time range' do
          let(:event_started_at) { artwork_pairing_config[:latest_date] + 1.week }

          it { is_expected.to be_empty }
        end

        context 'on the earliest date' do
          let(:event_started_at) { artwork_pairing_config[:earliest_date] }

          it { is_expected.to include(expectation(artwork1, artwork2, 1), expectation(artwork2, artwork1, 1)) }
        end

        context 'on the latest date' do
          let(:event_started_at) { artwork_pairing_config[:latest_date] }

          it { is_expected.to include(expectation(artwork1, artwork2, 1), expectation(artwork2, artwork1, 1)) }
        end

        context 'matches in the middle' do
          let(:event_started_at) { 10.days.ago }

          it { is_expected.to include(expectation(artwork1, artwork2, 1), expectation(artwork2, artwork1, 1)) }
        end
      end
    end

    describe 'having minimum pairing frequency' do
      # paired_frequency of 1 so far
      let!(:matching_sale) { create(:sale, merchandises: [merch1, merch2]) }
      let(:artwork_pairing_config) do
        { minimum_pairing_frequency: 2 }
      end

      context 'of 2' do
        it 'is empty with solitary sale' do
          expect(result).to be_empty
        end

        context 'with double sale' do
          before { create(:sale, merchandises: [merch1, merch2]) }

          it 'returns one pairing with frequency 2' do
            expect(result).to include(
              expectation(artwork1, artwork2, 2),
              expectation(artwork2, artwork1, 2)
            )
          end

          it 'further filters with tag filters' do
            create(:sale, :with_merchandise) # misses
            artwork_pairing_config.merge!(artwork_tag_filter_a_root: attributes_for(:tag_filter, :matches_all, tags: ['x']))

            expect(result).to eq([{ 'root_name' => artwork2.name, 'associated_artwork_name' => artwork1.name, 'paired_frequency' => 2 }])
            #expect(result).to eq([ expectation(artwork2, artwork1, 1) ])
          end
        end
      end
    end
  end
end
