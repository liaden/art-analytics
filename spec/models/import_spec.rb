describe Import do
  it { is_expected.to have_many(:artworks) }
  it { is_expected.to have_many(:merchandises) }
  it { is_expected.to have_one(:event) }

  it { is_expected.to validate_presence_of(:import_file_data) }
end