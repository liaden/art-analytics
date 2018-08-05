describe ImportMissingArtworks do
  let(:import) { create(:import) }

  describe "command arguments" do
    let(:args) { { name: 'name', import: import } }

    it "requires names" do
      args.delete(:name)
      expect(ImportMissingArtworks.run(args).errors.message[:names]).to_not be_nil
    end

    it "requires an import job" do
      args.delete(:import)
      expect(ImportMissingArtworks.run(args).errors.message[:import]).to_not be_nil
    end
  end

  describe ".run" do
    it "does not create duplicate Artworks" do
      create(:artwork, name: 'b')

      expect {
        ImportMissingArtworks.run(names: ['a', 'b'], import: import)
      }.to change{Artwork.count}.by(1)
    end

    it "does not mutate existing Artworks" do
      art = create(:artwork, name: 'b')

      ImportMissingArtworks.run(names: ['b'], import: import)

      expect(art).to eq art.reload
    end

    it "creates nothing during dry_run" do
      expect {
        ImportMissingArtworks.run(names: ['b'], import: import, dry_run: true)
      }.to_not change{Artwork.count}
    end

    it "associates with an existing import job" do
      ImportMissingArtworks.run(names: ['b'], import: import)

      expect(Artwork.where(import_id: import.id).size).to eq 1
    end
  end

  describe "#result" do
    it "does not include previously existing" do
      create(:artwork, name: 'b')
      result = ImportMissingArtworks.run(names: ['a', 'b'], import: import).result
      expect(result).to contain_exactly(Artwork.find_by(name: 'a'))
    end

    it "contains new Artwork" do
      result = ImportMissingArtworks.run(names: ['a'], import: import).result
      expect(result).to contain_exactly(Artwork.find_by(name: 'a'))
    end

    it "contains unpersisted Artwork during dry_run" do
      result = ImportMissingArtworks.run(names: ['a'], import: import, dry_run: true).result

      expect(result).to_not be_empty
      expect { result.first.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
