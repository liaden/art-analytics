describe ImportSales do
  let(:event) { create(:event) }

  def run(args)
    ImportSales.run(args)
  end

  let(:args) { { spreadsheet: empty_spreadsheet(['a'], ['canvas']), event: event, import: create(:import) } }

  let(:single_sale_spreadsheet) do
    make_spreadsheet(['a', 'a'], ['canvas', 'unsold_option'], # unsold option catches the case of a 0/nil quantity for MerchandiseSale
      [
        { ['a', 'canvas'] => 1, 'total' => 10}
      ])
  end

  let(:double_sale_spreadsheet) do
    make_spreadsheet(['a', 'a'], ['canvas', 'photopaper'],
      [
        {['a', 'canvas'] => 1, 'total' => 10},
        {['a', 'photopaper'] => 1, 'total' => 15}
      ])
  end

  let(:complex_sale_spreadsheet) do
    make_spreadsheet(['a', 'a'], ['canvas', 'photopaper'],
      [
        { ['a', 'canvas'] => 1, ['a', 'photopaper'] => 2, 'total' => 25, 'tags' => 'a,b,c'}
      ])
  end

  describe "command arguments" do
    def errors
      run(args).errors
    end

    describe "spreadsheet" do
      it "is required" do
        args.delete(:spreadsheet)
        expect(errors[:spreadsheet]).to_not be_nil
      end
    end

    describe "event" do
      it "is required" do
        args.delete(:event)
        expect(errors[:event]).to_not be_nil
      end

      it  "cannot have associated sales" do
        event.sales.create(attributes_for(:sale))
        expect(errors['event']).to_not be_nil
      end
    end

    describe "do_not_overwrite" do
      it "enables event to have sales" do
        event.sales.create(attributes_for(:sale))
        args[:do_not_overwrite] = false

        expect(errors).to be_nil
      end
    end
  end

  describe ".run" do
    it 'runs ImportMissingArtworks command' do
      expect_any_instance_of(ImportMissingArtworks).to receive(:run).and_call_original
      run(args)
    end

    it 'runs ImportMissingMerchandises command' do
      expect_any_instance_of(ImportMissingMerchandises).to receive(:run).and_call_original
      run(args)
    end

    context 'with empty spreadsheet' do
      it 'creates no Sales' do
        expect {run(args)}.to_not change{Sale.count}
      end

      it 'creates the event inventory' do
        expect {run(args)}.to change{EventInventoryItem.count}.by(1)
      end
    end

    context 'with one sale' do
      before { args.merge!(spreadsheet: single_sale_spreadsheet) }

      it 'persists the sale' do
        expect { run(args) }.to change{Sale.count}.by(1)
      end
    end

    context 'with one complex sale' do
      before { args.merge!(spreadsheet: complex_sale_spreadsheet) }

      it 'associates with multiple merchandises' do
        expect {
          expect { run(args) }.to change{MerchandiseSale.count}.by(2)
        }.to change{Sale.count}.by(1)
      end
    end

    context 'with one tagged sale' do
      before { args.merge!(spreadsheet: complex_sale_spreadsheet) }

      it 'attaches tag to sale model' do
        run(args)

        expect(Sale.last.tags).to eq ['a', 'b', 'c']
      end
    end
  end

  describe "#result" do
    def result
      run(args).result
    end

    context 'with empty spreadsheet' do
      it 'has no sales' do
        expect(result[:sales]).to eq []
      end

      [:new_merchandises, :new_artworks].each do |key|
        it "returns #{key}" do
          data = result

          expect(data.key?(key)).to eq true
          expect(data[key]).to_not be_empty
        end
      end
    end

    context 'with one sale' do
      context 'of one merchandise' do
        [:sales, :inventory_list].each do |key|
          it "returns a #{key}" do
            args.merge!(spreadsheet: single_sale_spreadsheet)

            data = result

            expect(data.key?(key)).to eq true
            expect(data[key]).to_not be_empty
          end
        end
      end

      context 'of multiple merchandises' do
      end
    end
  end
end
