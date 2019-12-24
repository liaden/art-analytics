describe 'scoped tags' do
  let(:tag_params) { {} }
  let(:headers) { {} }

  let(:resource) { create(:event, tags: event_tags) }
  let(:event_tags) { nil }

  let(:json_response) { JSON.parse(response.body).deep_symbolize_keys! }

  context '#index' do
    let(:event_tags) { ['event-1', '2-event-2'] }

    before { resource; get scoped_tags_path('event'), params: tag_params, headers: headers }

    it { expect(response).to be_successful }
    it { expect(response.body).to include('event-1', '2-event-2') }

    context 'json request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } }

      subject { json_response[:event].sort }

      it { is_expected.to include('event-1', '2-event-2') }
      it { expect(json_response.keys).to eq([:event]) }

      context 'no events' do
        let(:resource) {}

        it { is_expected.to eq([]) }
      end

      context 'with multiple events' do
        let(:resource) do
          create(:event, tags: 'e0')
          create(:event, tags: 'e1')
        end

        it { is_expected.to eq(['e0', 'e1']) }
      end

      context 'with prefix' do
        let(:tag_params) { { tag_prefix: '2-e' } }

        it { is_expected.to eq(['2-event-2']) }
      end
    end

    context 'with prefix' do
      let(:tag_params) { { tag_prefix: '2-e' } }

      it { expect(response.body).to include('2-event-2') }
    end
  end

  describe '#show' do
    let(:matching) { create(:event, tags: 'event-1').reload }
    let(:resources) { [matching, create(:event)] }
    let(:tag) { 'event-1' }

    before { resources; get scoped_tag_path('event', tag), params: tag_params, headers: headers }

    it { expect(response).to be_successful }
    it { expect(response.body).to include(matching.name) }

    context 'json request' do
      let(:headers) { { 'ACCEPT' => 'application/json' } }

      it { expect(response).to be_successful }

      it { expect(json_response).to include(id: tag) }
      it { expect(json_response.keys).to contain_exactly(:id, :matches) }
      it { expect(json_response[:matches].keys).to include(:event) }

      describe 'event match data' do
        subject { json_response[:matches][:event][0] }

        it { is_expected.to include(id: matching.id) }
        it { is_expected.to include(name: matching.name) }
      end
    end
  end
end
