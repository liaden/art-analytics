describe Merchandise do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to belong_to :artwork }

  it { is_expected.to be_kind_of(Importable) }

  it 'persists to database' do
    expect{create(:merchandise)}.to change{Merchandise.count}.by(1)
  end
end
