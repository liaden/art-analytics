require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  let(:params) { {} }

  describe '#index' do
    subject(:json_response) do
      get(:index, params: params)
      JSON.parse(response.body).symbolize_keys
    end

    context 'no resource specified' do
      it { is_expected.to eq(event: [], artwork: [], merchandise: []) }

      context 'with models' do
        let(:artwork) { create(:artwork, tags: artwork_tags) }
        let!(:mercahndise) { create(:merchandise, tags: ['tag1']) }

        it { is_expected.to eq(artwork: [], event: [], merchandise: ['tag1']) }

        context 'with prefix' do
          before { params.merge!(tag_prefix: 'ta') }

          let!(:more_merch) { create(:merchandise, tags: ['tag2']) }
          let!(:merch_no_match) { create(:merchandise, tags: ['zzzzzz']) }

          it { is_expected.to eq(artwork: [], event: [], merchandise: ['tag1', 'tag2']) }
        end
      end
    end

    context 'event' do
      before { params[:resources] = [:event] }

      it { is_expected.to eq(event: []) }
    end
  end
end
