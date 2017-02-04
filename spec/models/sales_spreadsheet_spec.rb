describe SalesSpreadsheet do
  def headers(columns)
    SalesSpreadsheet::LEADING_COLUMNS.map() { nil } + columns + SalesSpreadsheet::TRAILING_COLUMNS.map() { nil }
  end

  def subheaders(columns)
    SalesSpreadsheet::LEADING_COLUMNS + columns + SalesSpreadsheet::TRAILING_COLUMNS
  end

  describe '#headers' do

    def instantiate(headers,subheaders)
      SalesSpreadsheet.new(headers, subheaders, [] )
    end

    context 'no artwork, no merchandise' do
      it "raises empty sheet error" do
        expect {
          instantiate(headers([]), subheaders([]))
        }.to raise_error(SalesSpreadsheet::EmptyHeaders)
      end
    end

    context 'headers and subheaders are wrong size' do
      it "raises if headers is smaller than subheaders" do
        expect {
          instantiate(headers([]), subheaders(['a']))
        }.to raise_error(SalesSpreadsheet::MismatchedHeaders)
      end

      it "raises if headers are larger than subheaders" do
        expect {
          instantiate(headers(['a']), subheaders([]))
        }.to raise_error(SalesSpreadsheet::MismatchedHeaders)
      end
    end

    context 'duplicate (header,subheader) pair' do
      it "raises" do
        expect {
          instantiate(headers(['a', 'a']), subheaders(['b', 'b']))
        }.to raise_error(SalesSpreadsheet::DuplicateHeaderSubheader)
      end
    end

    context 'it expects LEADING_COLUMNS in proper order' do
      it 'raises error' do
        expect{
          instantiate(['h'], ['s'])
        }.to raise_error(SalesSpreadsheet::UnexpectedColumn)
      end
    end

    context 'one merchandise for artwork' do
      it 'produces single pairing' do
        expect(
          instantiate(headers(['h']), subheaders(['s'])).headers
        ).to contain_exactly(['h', 's'])
      end
    end

    context 'multiple merchandise for artwork' do
      it 'produces multiple pairings' do
        expect(
          instantiate(headers(['h', nil, nil]), subheaders(['s1', 's2', 's3'])).headers
        ).to contain_exactly(['h','s1'], ['h','s2'], ['h','s3'])
      end

      it 'handles grouping across multiple headers with different length subheaders' do
        expect(
          instantiate(headers(['h1', nil, 'h2', 'h3']), subheaders(['s11', 's12', 's21', 's31'])).headers
        ).to contain_exactly(['h1','s11'], ['h1','s12'], ['h2','s21'], ['h3', 's31'])
      end
    end
  end

  describe '#sales_data' do
    def instantiate(*event_data)
      SalesSpreadsheet.new(headers(header), subheaders(subheader), event_data)
    end

    let(:header) { ['h1', nil, 'h2', 'h3'] }
    let(:subheader) { ['s11', 's12', 's21', 's31'] }

    context "invalid row lengths" do
      it "raises BadRow with shorter row" do
        expect {
          instantiate(
            ['0', '0', nil, nil, "1", "c,s,v"], # 1 too short
            ['0', '0', nil, nil, "1", nil, "c,s,v"]
          )
        }.to raise_error(SalesSpreadsheet::BadRow)
      end

      it "raises BadRow with longer row" do
        expect {
          instantiate(
            ['0', '0', nil, nil, "1", nil, "c,s,v"],
            ['0', '0', nil, nil, "1", nil, nil, "c,s,v"] # 1 too long
          )
        }.to raise_error(SalesSpreadsheet::BadRow)
      end
    end

    context "tags" do
      it "parses nil as []" do
        expect(
          instantiate(['0', '0', nil, nil, "1", nil, nil]).sales_data.first[:tags]
        ).to eq []
      end

      it "parses 'tag' as ['tag']" do
        expect(
          instantiate(['0', '0', nil, nil, "1", nil, 'tag']).sales_data.first[:tags]
        ).to eq ['tag']
      end

      it "parses csv" do
        expect(
          instantiate(['0', '0', nil, nil, "1", nil, "c,s,v"]).sales_data.first[:tags]
        ).to eq ['c', 's', 'v']
      end
    end

    context "merchandise quantity" do
      it "cannot be negative" do
        expect{
          instantiate(['0', '0', nil, nil, "-1", nil, "c,s,v"])
        }.to raise_error(SalesSpreadsheet::BadRow)
      end

      it "defaults nil to 0" do
        sales_data = instantiate(['0', '0', nil, nil, "1", nil, "c,s,v"]).sales_data
        expect(
          sales_data.first[:merchandise_sold].first
        ).to eq({artwork_name: 'h1', merch_name: 's11', quantity: 0})
      end

      it "converts to integers" do
        sales_data = instantiate(['0', '0', nil, nil, "1", nil, "c,s,v"]).sales_data
        expect(
          sales_data.first[:merchandise_sold][2]
        ).to eq({artwork_name: 'h2', merch_name: 's21', quantity: 1})
      end
    end

    context "total" do
      it "converts as a BigDecimal" do
        total = instantiate(['1.00', '0', nil, nil, "1", nil, "c,s,v"]).sales_data.first[:total]

        expect(total).to be_a(BigDecimal)
        expect(total).to eq BigDecimal('1.00')
      end

      it "cannot be negative" do
        expect{
          instantiate(['-1.00', '0', nil, nil, "1", nil, "c,s,v"])
        }.to raise_error(SalesSpreadsheet::BadRow)
      end

      it "cannot be nil" do
        expect{
          instantiate([nil, '0', nil, nil, "1", nil, "c,s,v"])
        }.to raise_error(SalesSpreadsheet::BadRow)
      end
    end

    context "sold_on" do
      it "converts to integer" do
        expect(
          instantiate(['0', '0', nil, nil, "1", nil, "c,s,v"]).sales_data.first[:sold_on]
        ).to eq 0
      end

      it "cannot be negative"do
        expect {
          instantiate(['0', '-1', nil, nil, "1", nil, "c,s,v"])
        }.to raise_error(SalesSpreadsheet::BadRow)
      end

      it "cannot be nil" do
        expect {
          instantiate(['0', nil, nil, nil, "1", nil, "c,s,v"])
        }.to raise_error(SalesSpreadsheet::BadRow)
      end
    end
  end
end
