describe Importable do
  silence_stream(STDOUT) do
    ActiveRecord::Schema.define do
      create_table :importable_classes, force: true do |t|
        t.integer :import_id
      end
    end
  end

  class ImportableClass < ActiveRecord::Base
    include Importable
  end

  let(:import) { create(:import) }

  describe '#imported?' do
    it { expect(ImportableClass.new(import: import)).to be_imported }
    it { expect(ImportableClass.new).to_not be_imported }
  end

  describe ImportableClass do
    it { is_expected.to belong_to(:import) }
  end
end