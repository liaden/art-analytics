describe Purchase do
  it { is_expected.to validate_presence_of(:sale_price) }

  it "persists to the database" do
    expect{create(:purchase)}.to change{Purchase.count}.by(1)
  end

  it "requires at least 1 merchandise" do
    expect(build(:purchase, merchandises: [])).to_not be_valid
  end
end
