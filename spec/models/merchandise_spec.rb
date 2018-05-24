describe Merchandise do
  it { is_expected.to be_kind_of(Importable) }
  it { is_expected.to be_kind_of(Taggable) }

  it 'defaults to known item' do
    is_expected.to be_known_item
  end

  it 'persists to database' do
    expect{create(:merchandise)}.to change{Merchandise.count}.by(1)
  end

  it 'allows for multiple with one artwork' do
    merch = create(:merchandise, name: 'small')
    expect(build(:merchandise, name: 'large', artwork: merch.artwork)).to be_valid
  end

  it 'allows for same name across different artworks' do
    create(:merchandise, name: 'small')
    expect(build(:merchandise, name: 'small')).to be_valid
  end

  it 'can have a dimension' do
    create(:merchandise, dimension: create(:dimension))
  end

  context 'an unknown_item' do
    it 'is unique for unknown artwork record' do
      item = build(:unknown_merchandise,
        name: 'abcd', # unique name
        artwork: nil)

      expect(item).to_not be_valid
    end

    it 'is unique for known artwork record' do
      merch = create(:unknown_merchandise)
      item = build(:unknown_merchandise,
                   name: 'abcd', # unique name
                   artwork: merch.artwork)
      expect(item).to_not be_valid
    end

    it 'does not require an associated artwork' do
      expect(build(:unknown_merchandise)).to be_valid
    end
  end
end
