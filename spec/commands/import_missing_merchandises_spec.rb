describe ImportMissingMerchandises do
  let(:import) { create(:import) }
  let(:b_art) { create(:artwork, name: 'b')}
  let(:a_art) { create(:artwork, name: 'a')}

  let(:args) { {import: import, merchandise_by_artwork_name: { 'b' => ['1'] }, artworks: [b_art], allow_n_plus_one: true } }

  def create_merch_for(artwork)
    create(:merchandise, artwork: artwork, name: args[:merchandise_by_artwork_name][artwork.name].first)
  end

  describe "command arguments" do
    def error
      ImportMissingMerchandises.run(args).errors
    end

    it "requires an import" do
      args.delete(:import)
      expect(error[:import]).to_not be_nil
    end

    describe "artworks" do
      it "is required" do
        args.delete(:artworks)
        expect(error[:artworks]).to_not be_nil
      end

      it "requires Artwork models" do
        args.merge!(:artworks => [Object.new])
        expect(error[:artworks]).to_not be_nil
      end
    end

    describe "merchandise_by_artwork_name" do
      it "is required" do
        args.delete(:merchandise_by_artwork_name)
        expect(error[:merchandise_by_artwork_name]).to_not be_nil
      end

      it "is a hash with with array of strings" do
        expect(error).to be_nil
      end
    end

    it "requires artworks to match merchandise_by_artwork_name" do
      args.merge!(artworks: [a_art])
      expect(error['artworks_and_merchandises']).to_not be_nil
    end
  end

  describe ".run" do
    it "does not create duplicate merchandise" do
      merch = create_merch_for(b_art)
      expect { ImportMissingMerchandises.run(args) }.to_not change{Merchandise.count}
    end

    it "does not mutate existing merchandise" do
      merch = create_merch_for(b_art)
      ImportMissingMerchandises.run(args)
      expect(merch).to eq merch.reload
    end

    it "creates nothing during dry run" do
      expect { ImportMissingMerchandises.run(args.merge!(dry_run: true)) }.to_not change{Merchandise.count}
    end
  end

  describe "#result" do
    it "does not include previously existing" do
      merch = create_merch_for(b_art)

      expect(ImportMissingMerchandises.run(args).result).to be_empty
    end

    it "contains new Merchandise" do
      expect(ImportMissingMerchandises.run(args).result).to_not be_empty
    end

    it "contains unpersisted Merchandise during dry_run" do
      merchandises = ImportMissingMerchandises.run(args.merge(dry_run: true)).result
      expect(merchandises.all? { |m| !m.persisted? }).to eq false
    end
  end
end