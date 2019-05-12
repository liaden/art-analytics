# frozen_string_literal: true

describe Artwork do
  it 'saves to the db' do
    expect { create(:artwork) }.to change{ Artwork.count }.by(1)
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to have_many :merchandises }

  it { is_expected.to be_kind_of(Importable) }
end
