describe Event do
  it { is_expected.to validate_presence_of(:started_at) }
  it { is_expected.to validate_presence_of(:ended_at) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to be_kind_of(Importable) }

  it "validates end is after start" do
    expect(build(:event, started_at: Date.tomorrow, ended_at: Date.yesterday)).to be_invalid
  end

  it "can start and end on the same day" do
    expect(build(:event, started_at: Date.today, ended_at: Date.today)).to be_valid
  end
end