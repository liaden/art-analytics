# frozen_string_literal: true

describe ReplaceArtwork do
  let(:replacee) { create(:artwork, name: 'a') }
  let(:replacer) { create(:artwork, name: 'b') }

  let!(:params) { { replacee_name: replacee.name, replacer_name: replacer.name } }

  describe 'validations' do
    after { expect{ ReplaceArtwork.run!(params) }.to raise_error(Mutations::ValidationException) }

    it 'requires replacee_name' do
      params.delete(:replacee_name)
    end

    it 'requires replacer_name' do
      params.delete(:replacer_name)
    end
  end

  describe '#run' do
    let!(:replacees_merch) { create(:merchandise, artwork: replacee) }

    context 'no merch on new artwork' do
      it 'moves replacees_merch to replacer' do
        ReplaceArtwork.run!(params)

        expect(replacee.reload.merchandises.size).to eq 0
        expect(replacer.reload.merchandises.size).to eq 1
      end
    end

    context 'no overlapping merch on new artwork' do
      let!(:replacers_merch) { create(:merchandise, name: replacees_merch.name + ' other', artwork: replacer) }

      it 'moves replacees_merch to replacer' do
        ReplaceArtwork.run!(params)

        expect(replacee.reload.merchandises.size).to eq 0
        expect(replacer.reload.merchandises.size).to eq 2
      end
    end

    context 'same named merchandise on both' do
      let!(:replacers_merch) { create(:merchandise, name: replacees_merch.name, artwork: replacer) }

      it 'deletes replacees_merch' do
        expect {
          ReplaceArtwork.run!(params)
        }.to change { Merchandise.count }.by(-1)

        expect(replacers_merch.reload.artwork_id).to eq replacer.id
        expect(replacer.reload.merchandises.size).to eq 1
      end

      it 'deletes the unknown item' do
        create(:unknown_merchandise, artwork: replacee)
        create(:unknown_merchandise, artwork: replacer)

        expect {
          ReplaceArtwork.run!(params)
        }.to change { Merchandise.count }.by(-2)
      end
    end
  end
end
