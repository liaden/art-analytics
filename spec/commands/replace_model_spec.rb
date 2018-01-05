describe ReplaceModel do
  let(:params) do
    { replacee: replacee,
      replacer: replacer,
      related_tables: related_tables,
      field_name: field_name
    }
  end

  let(:replacee) { create(:artwork, :with_merchandise) }
  let(:replacer) { create(:artwork) }
  let(:related_tables) { [ Merchandise ] }
  let(:field_name) { :artwork_id }

  describe 'validations' do
    after { expect{ReplaceModel.run!(params)}.to raise_error(Mutations::ValidationException) }

    it 'requires replacee' do
      params.delete(:replacee)
    end

    it 'requires replacer' do
      params.delete(:replacer)
    end

    it 'requires field_name' do
      params.delete(:field_name)
    end

    it 'requires related_tables' do
      params.delete(:related_tables)
    end

    it 'requires an array of related_tables' do
      params[:related_tables] = Merchandise
    end

    it 'cannot be replaced twice' do
      replacee.replaced_by = create(:artwork)
    end
  end

  describe '.run' do
    before { ReplaceModel.run!(params) }

    it 'related_tables do not point to replacee' do
      replacee.reload
      expect(replacee.merchandises).to be_empty
    end

    it 'records the replacer on the replacee' do
      replacee.reload
      expect(replacee.replaced_by).to_not be_nil
    end

    it 'migrates rows from related_tables to replacer' do
      replacer.reload
      expect(replacer.merchandises).to_not be_empty
    end
  end
end
