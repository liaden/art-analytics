describe Sale do
  it { is_expected.to validate_presence_of(:sale_price) }
  it { is_expected.to belong_to(:event) }

  it "persists to the database" do
    expect{create(:sale)}.to change{Sale.count}.by(1)
  end

  it "requires at least 1 merchandise" do
    expect(build(:sale, merchandises: [])).to_not be_valid
  end

  context "at an event" do
    let(:event) { create(:event) }
    it "must occur during event" do
      expect(build(:sale, sold_on: event.started_at - 1.day, event: event)).to be_invalid
    end
  end
end
