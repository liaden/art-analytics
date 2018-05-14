# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Merchandise.create_unknown_for(nil) unless Merchandise.unknown_artwork_item.present?

if Rails.env.development?
  ActiveRecord::Base.transaction do
    [
      { name: 'ohayocon',
        started_at: '1/15/2016',
        duration: 3,
        file: '../analytics-data/art-analytics-event-transactions - ohayocon.csv'
      },
      { name: 'momocon',
        started_at: '5/26/2016',
        duration: 4,
        file: '../analytics-data/art-analytics-event-transactions - momocon.csv'
      },
      { name: 'millenium',
        started_at: '7/8/2016',
        duration: 3,
        file: '../analytics-data/art-analytics-event-transactions - millenium.csv'
      },
      { name: 'state street',
        started_at: '7/21/2016',
        duration: 4,
        file: '../analytics-data/art-analytics-event-transactions - state_street.csv'
      },
      { name: 'GCAF',
        started_at: '11/4/2016',
        duration: 3,
        file: '../analytics-data/art-analytics-event-transactions - GCAF.csv'
      },
      { name: 'ohayocon',
        started_at: '1/13/2017',
        duration: 3,
        file: '../analytics-data/ohayocon-2017.csv',
      },
      { name: 'winter pancakes & booze',
        started_at: '2/24/2017',
        duration: 3,
        file: '../analytics-data/winter-pancakes-booze-2017.csv',
      },
      { name: 'shutocon',
        started_at: '3/17/2017',
        duration: 3,
        file: '../analytics-data/shutocon-2017.csv',
      },
      { name: 'panoply',
        started_at: '4/28/2017',
        duration: 3,
        file: '../analytics-data/panoply-2017.csv',
      },
      { name: 'megacon',
        started_at: '5/25/2017',
        duration: 4,
        file: '../analytics-data/megacon-2017.csv',
      },
      { name: 'wells',
        started_at: '6/10/2017',
        duration: 2,
        file: '../analytics-data/wells-2017.csv',
      },
      { name: 'exxxotica',
        started_at: '6/23/2017',
        duration: 3,
        file: '../analytics-data/exxxotica-2017.csv',
      },
      { name: 'goldcoast',
        started_at: '6/17/2017',
        duration: 2,
        file: '../analytics-data/goldcoast-2017.csv',
      },
      { name: 'state street',
        started_at: '7/20/2017',
        duration: 4,
        file: '../analytics-data/state-street-2017.csv',
      },
      { name: 'dragoncon',
        started_at: '9/1/2017',
        duration: 4,
        file: '../analytics-data/dragoncon-2017.csv',
      },
      { name: 'summer pancakes and booze',
        started_at: '9/22/2017',
        duration: 2,
        file: '../analytics-data/summer-pancakes-booze-2017.csv',
      },
      { name: 'winter pancakes and booze',
        started_at: '2/23/2018',
        duration: 2,
        file: '../analytics-data/winter-pancakes-booze-2018.csv',
      },
      { name: 'shutocon',
        started_at: '3/23/2018',
        duration: 3,
        file: '../analytics-data/shutocon-2018.csv',
      },
    ].each do |data|
      puts "Processing #{data[:file]}"

      ImportSales.run(
        event: Event.create(
          name: data[:name],
          started_at: Date.strptime(data[:started_at], '%m/%d/%Y'),
          ended_at: Date.strptime(data[:started_at], '%m/%d/%Y') + data[:duration] - 1
        ),
        import: Import.create(import_file_data: File.read(data[:file])),
        spreadsheet: EventSalesData.load(data[:file])
      ) if File.exist?(data[:file])
    end

    [
      {
        replacee_name: 'A fish may love a bird',
        replacer_name: 'A Fish May Love A Bird'
      },
      {
        replacee_name: 'AfterGlow',
        replacer_name: 'Afterglow'
      },
      {
        replacee_name: 'Bakku-Shan',
        replacer_name: 'Bakku-shan'
      },
      {
        replacee_name: 'Familiar Skib',
        replacer_name: 'Familiar Skin'
      },
      {
        replacee_name: 'Guingin',
        replacer_name: 'Guingin Of The Rumblestrudt'
      },
      {
        replacee_name: 'Persephone',
        replacer_name: "Persephone's Mischief"
      },
      {
        replacee_name: 'Quandry',
        replacer_name: 'Quandary'
      },
      {
        replacee_name: 'StarSong',
        replacer_name: 'Starsong'
      }
    ].each do |data|
      puts "Replacing \"#{data[:replacee_name]}\" with \"#{data[:replacer_name]}\""
      ReplaceArtwork.run!(**data)
    end

    merch_mapping = { '8x8' => 'Small', '8x10' => 'Small', '8x12' => 'Small', '11x14' => 'Large', '12x18' => 'Large' }
    Merchandise.where(name: merch_mapping.keys).each do |merch|
      new_name = merch_mapping[merch.name]
      puts "Processing #{merch.name} for #{merch.artwork.name}"
      if replacer = merch.artwork.merchandises.where(name: new_name).first
        ReplaceMerchandise.run!(replacee: merch, replacer: replacer)
      else
        merch.update!(name: new_name)
      end
    end

    # Detect any invalid data
    [ Artwork, Merchandise, MerchandiseSale, Sale, Event ].each do |table|
      table.all.each { |i| puts i.errors.inspect unless i.valid?  }
    end
  end
end
