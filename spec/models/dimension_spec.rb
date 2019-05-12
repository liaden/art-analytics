# frozen_string_literal: true

describe Dimension do
  let(:dimension) { create(:dimension, width: 8, height: 12) }

  it 'saves to the db' do
    expect { create(:dimension) }.to change{ Dimension.count }.by(1)
  end

  describe 'validations' do
    [:width, :height, :thickness].each do |attr|
      it "#{attr} cannot be negative" do
        dim = build(:dimension, attr => "-1")
        expect(dim).to_not be_valid
      end
    end

    [:width, :height].each do |attr|
      it "#{attr} cannot be zero" do
        dim = build(:dimension, attr => 0)
        expect(dim).to_not be_valid
      end
    end
  end

  describe 'uniqueness' do
    it 'allows landscape and portrait' do
      create(:dimension, width: dimension.height, height: dimension.width)
    end

    it 'allows for different null thickness and a specified thickness' do
      expect(dimension.thickness).to eq 0
      create(:dimension, width: dimension.width, height: dimension.height, thickness: 1)
    end

    it 'raises exception' do
      expect {
        create(
          :dimension,
          width:  dimension.width,
          height: dimension.height
        )
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  [:width, :height, :thickness].each do |attr|
    it "#{attr} uses decimal numbers" do
      dim = create(:dimension, attr => "8.5")
      dim.reload
      expect(dim.send(attr).to_s).to eq "8.5"
    end
  end

  it 'defaults thickness to 0' do
    expect(Dimension.create(width: 8, height: 8).thickness).to eq 0
  end
end
