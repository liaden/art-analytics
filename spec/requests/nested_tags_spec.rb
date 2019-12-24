describe 'nested tags' do
  let(:event) { create(:event, tags: event_tags) }
  let(:event_tags) { [] }

  def json_response
    JSON.parse(response.body)
  end

  describe '#index' do
    before { get event_tags_path(event) }

    it { expect(json_response['tags']).to eq([]) }

    context 'missing parent' do
      let(:event) { double(:event, id: 0) }

      it { expect(response.status).to eq(404) }
    end

    context 'with tags' do
      let(:event_tags) { ['tag1', 'tag2'] }

      it { expect(json_response['tags']).to include('tag1', 'tag2') }
    end
  end

  describe '#create' do
    let(:tag_params) { {} }

    before { post event_tags_path(event), params: tag_params }

    it { expect(response).to_not be_successful }

    context 'one tag' do
      let(:tag_params) { { tag: new_tag } }
      let(:new_tag) { 'tag' }

      it { expect(response).to be_successful }
      it { expect(event.reload.tags).to include('tag') }
      it { expect(json_response['tags']).to include('tag') }
      it { expect(json_response['created']).to include('tag') }

      context 'that already exists' do
        let(:event_tags) { ['tag'] }

        it { expect(json_response['created']).to be_blank }
      end
    end

    context 'many tags' do
      let(:tag_params) { { tags: ['tag1', 'tag2'] } }

      it { expect(response).to be_successful }
      it { expect(event.reload.tags).to include('tag1', 'tag2') }
      it { expect(json_response['tags']).to include('tag1', 'tag2') }
      it { expect(json_response['created']).to include('tag1', 'tag2') }
    end

    context 'missing parent' do
      let(:event) { double(:event, id: 0 ) }

      it { expect(response.status).to eq(404) }
    end
  end

  describe '#update' do
    let(:event_tags) { ['tag1', 'tag2'] }
    let(:old_tag) { 'tag1' }
    let(:tag_params) { {} }

    before { put event_tag_path(event, old_tag), params: tag_params }

    it { expect(response).to_not be_successful }

    context 'tag' do
      let(:tag_params) { { tag: 'tag3' } }

      it { expect(response).to be_successful }
      it { expect(event.reload.tags).to contain_exactly('tag3', 'tag2') }
      it { expect(json_response['tags']).to contain_exactly('tag2', 'tag3') }
    end

    context 'missing parent' do
      let(:event) { double(:event, id: 0 ) }

      it { expect(response.status).to eq(404) }
    end
  end

  describe '#destroy' do
    before { delete event_tag_path(event, 'tag') }

    it { expect(response.status).to eq(404) }

    context 'with tags' do
      let(:event_tags) { ['tag'] }

      it { expect(response).to be_successful }
    end

    context 'missing parent' do
      let(:event) { double(:event, id: 0 ) }

      it { expect(response.status).to eq(404) }
    end
  end
end
