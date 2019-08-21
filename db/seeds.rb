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
        tags: 'con,anime,indoor',
        file: '../analytics-data/art-analytics-event-transactions - ohayocon.csv'
      },
      { name: 'momocon',
        started_at: '5/26/2016',
        duration: 4,
        tags: 'con,indoor',
        file: '../analytics-data/art-analytics-event-transactions - momocon.csv'
      },
      { name: 'millenium',
        started_at: '7/8/2016',
        duration: 3,
        tags: 'festival,outdoor',
        file: '../analytics-data/art-analytics-event-transactions - millenium.csv'
      },
      { name: 'state street',
        started_at: '7/21/2016',
        duration: 4,
        tags: 'festival,outdoor',
        file: '../analytics-data/art-analytics-event-transactions - state_street.csv'
      },
      { name: 'GCAF',
        started_at: '11/4/2016',
        duration: 3,
        tags: 'festival,outdoor',
        file: '../analytics-data/art-analytics-event-transactions - GCAF.csv'
      },
      { name: 'ohayocon',
        started_at: '1/13/2017',
        duration: 3,
        tags: 'con,anime,indoor',
        file: '../analytics-data/ohayocon-2017.csv',
      },
      { name: 'winter pancakes & booze',
        started_at: '2/24/2017',
        duration: 3,
        tags: 'bar,nighttime,indoor',
        file: '../analytics-data/winter-pancakes-booze-2017.csv',
      },
      { name: 'shutocon',
        started_at: '3/17/2017',
        duration: 3,
        tags: 'con,indoor',
        file: '../analytics-data/shutocon-2017.csv',
      },
      { name: 'panoply',
        started_at: '4/28/2017',
        duration: 3,
        tags: 'festival,outdoor',
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
        tags: 'festival,outdoor',
        file: '../analytics-data/wells-2017.csv',
      },
      { name: 'exxxotica',
        started_at: '6/23/2017',
        duration: 3,
        tags: 'con,indoor,nighttime',
        file: '../analytics-data/exxxotica-2017.csv',
      },
      { name: 'goldcoast',
        started_at: '6/17/2017',
        duration: 2,
        tags: 'festival,outdoor',
        file: '../analytics-data/goldcoast-2017.csv',
      },
      { name: 'state street',
        started_at: '7/20/2017',
        duration: 4,
        tags: 'festival,outdoor',
        file: '../analytics-data/state-street-2017.csv',
      },
      { name: 'dragoncon',
        started_at: '9/1/2017',
        duration: 4,
        tags: 'con,indoor',
        file: '../analytics-data/dragoncon-2017.csv',
      },
      { name: 'summer pancakes and booze',
        started_at: '9/22/2017',
        duration: 2,
        tags: 'bar,nighttime,indoor',
        file: '../analytics-data/summer-pancakes-booze-2017.csv',
      },
      { name: 'winter pancakes and booze',
        started_at: '2/23/2018',
        duration: 2,
        tags: 'bar,nighttime,indoor',
        file: '../analytics-data/winter-pancakes-booze-2018.csv',
      },
      { name: 'shutocon',
        started_at: '3/23/2018',
        duration: 3,
        tags: 'con,indoor',
        file: '../analytics-data/shutocon-2018.csv',
      },
      { name: 'panoply',
        started_at: '4/27/2018',
        duration: 3,
        tags: 'festival,outdoor',
        file: '../analytics-data/panoply-2018.csv',
      },
      { name: 'acen',
        started_at: '5/18/2018',
        duration: 3,
        tags: 'con,anime,indoor',
        file: '../analytics-data/acen-2018.csv',
      },
      { name: 'millenium',
        started_at: '7/6/2018',
        duration: 3,
        tags: 'festival,outdoor',
        file: '../analytics-data/millenium-2018.csv',
      },
      { name: 'state street',
        started_at: '7/19/2018',
        duration: 4,
        tags: 'festival,outdoor',
        file: '../analytics-data/state-street-2018.csv',
      },
    ].each do |data|
      puts "Processing #{data[:file]}"

      ImportSales.run(
        event: Event.create(
          name: data[:name],
          tags: data[:tags],
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
        replacee_name: 'Pilgramage',
        replacer_name: 'Pilgrimage'
      },
      {
        replacee_name: 'Quandry',
        replacer_name: 'Quandary'
      },
      {
        replacee_name: 'StarSong',
        replacer_name: 'Starsong'
      },
      {
        replacee_name: 'Thorny Alice',
        replacer_name: 'Wildflower Alice'
      }
    ].each do |data|
      puts "Replacing \"#{data[:replacee_name]}\" with \"#{data[:replacer_name]}\""
      ReplaceArtwork.run!(**data)
    end

    merch_mapping = {
      '8x8' => 'Small',
      '8x10' => 'Small',
      '8x12' => 'Small',
      '11x14' => 'Large',
      '12x18' => 'Large',
      'Watercolor' => 'Watercolor Print',
      '16x20 Camvas' => '16x20 Canvas',
      '60' => 'Watercolor Print', # Vasalisa
      'Canvas 8x12' => '8x12 Canvas',
      'Watercolor Print Large' => 'Large Watercolor Print',
      '225' => 'Large Watercolor' # Aegis-Hearted Framed Watercolor
    }

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

    square = [
      "Afterglow",
      "Alabaster",
      "Chrysalis",
      "Kintsugi",
      "Nikomis",
      "Sloth",
      "SourPuss",
      "Tempest",
      "Wrath"
    ]

    squarish = {
      portrait: [
        "Aegis-Hearted",
        "Affirmation",
        "Aurora",
        "Consent",
        "Detonator",
        "Dowry",
        "Flying Lessons",
        "Force Of Hand",
        "Nesting Box",
        "Now You See Me",
        "Page of Pentacles",
        "Queen Of Swords",
      ],
      landscape: [
        "A Fish May Love A Bird",
        "Bakku-shan",
        "Coronation",
        "Clarice's Echo",
        "Low Tide",
        "Quandary",
        "Ursula's Promise"
      ]
    }

    more_rectangle = {
      portrait: [
        "Baldr",
        "Familiar Skin",
        "Guingin Of The Rumblestrudt",
        "Pallas Justice",
        "Starlet",
        "Wildflower Alice"
      ],
      landscape: [
        "Fernweh",
        "Fire One",
        "Luxuria",
        "Opalescence",
        "Persephone's Mischief",
        "Princess",
        "Starsong",
        "Windbreak"
      ]
    }

    [ [ :Small,  8,  8, square ],
      [ :Small,  8, 10, squarish[:portrait] ],
      [ :Small, 10,  8, squarish[:landscape] ],
      [ :Small,  8, 12, more_rectangle[:portrait] ],
      [ :Small, 12,  8, more_rectangle[:landscape] ],
      [ :Large, 11, 14, squarish[:portrait] ],
      [ :Large, 14, 11, squarish[:landscape] ],
      [ :Large, 11, 17, more_rectangle[:portrait] ],
      [ :Large, 17, 11, more_rectangle[:landscape] ],
      [ 'Watercolor Print', 11, 14, squarish[:portrait] ],
      [ 'Watercolor Print', 14, 11, squarish[:landscape] ],
      [ 'Watercolor Print', 11, 17, more_rectangle[:portrait] ],
      [ 'Watercolor Print', 17, 11, more_rectangle[:landscape] ]
    ].each do |merch_name, width, height, artwork_names|
      puts "Processing #{merch_name} with width=#{width} and landscape=#{height}"
      Merchandise.joins(:artwork).where(
        name: merch_name,
        artworks: { name: artwork_names }
      ).update_all(dimension_id: Dimension.find_or_create_by(width: width, height: height).id)
    end

    Merchandise.includes(:artwork).where(dimension_id: nil, unknown_item: false, artworks: {replaced_by_id: nil}).each do |m|
      puts "Artwork #{m.artwork.name} is missing a dimension for merchandise #{m.name}"
    end

    puts Merchandise.where.not(dimension_id: nil).count
  end
end
