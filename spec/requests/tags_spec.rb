describe 'tags' do
  let(:tag_params) { {} }
  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys! }
  let(:headers) { {} }

  describe '#index' do
    let(:resources) { [] }
    let(:headers) { { 'ACCEPT' => 'application/json' } }

    before { resources; get tags_path, params: tag_params, headers: headers }

    it { expect(response).to be_successful }
    it { expect(json_response).to include(event: []) }
    it { expect(json_response).to include(artwork: []) }
    it { expect(json_response).to include(merchandise: []) }

    context 'with prefix' do
      let(:tag_params) { { tag_prefix: 'pre' } }

      context 'with tagged event' do
        let(:resources) { [create(:event, tags: ['event', 'pre-event'])] }

        it { expect(json_response).to include(event: ['pre-event']) }
      end

      context 'with tagged artwork' do
        let(:resources) { create(:artwork, tags: ['artwork', 'pre-artwork']) }
        it { expect(json_response).to include(artwork: ['pre-artwork']) }
      end

      context 'with tagged merchandise' do
        let(:resources) { create(:merchandise, tags: ['merch', 'pre-merch']) }
        it { expect(json_response).to include(merchandise: ['pre-merch']) }
      end
    end

    context 'with resources query parameter' do
      let(:tag_params) { { resources: ['event', 'artwork'] } }

      let(:resources) { [create(:artwork, tags: 'art1'), create(:event, tags: 'event1'), create(:merchandise, tags: 'merch1')] }

      it { expect(json_response.keys).to contain_exactly(:event, :artwork) }
      it { expect(json_response).to include(event: ['event1']) }
      it { expect(json_response).to include(artwork: ['art1']) }
    end
  end

  describe '#show' do
    let(:resources) { [] }
    let(:tag) { 'tag1' }

    before { resources; get tag_path(tag), params: tag_params, headers: headers }

    context 'with tagged artwork' do
      let(:matching) { create(:artwork, tags: tag) }
      let!(:resources) { [matching, create(:artwork, tags: 'other')] }

      context 'json' do
        let(:headers) { { 'ACCEPT' => 'application/json' } }

        it { expect(json_response[:matches][:artwork]).to include(id: matching.id, name: matching.name) }
      end
    end

    context 'with tagged event' do
      let(:matching) { create(:event, tags: tag).reload }
      let(:resources) { [matching, create(:event, tags: 'other').reload] }

      it { expect(response).to be_successful }
      it { expect(response.body).to include(matching.name) }
      it { expect(response.body).to_not include(resources.last.name) }

      context 'json' do
        let(:headers) { { 'ACCEPT' => 'application/json' } }

        it { expect(json_response[:matches][:event]).to include(id: matching.id, name: matching.name) }
      end
    end
  end
end
