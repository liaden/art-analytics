class ArtworkPairings
  attr_accessor :options

  def initialize(options = {})
    @options = options
    @options[:minimum_pairing_frequency] ||= 1
  end

  def run
    ActiveRecord::Base.connection.exec_query(to_sql).to_hash
  end

  def to_sql
    ActiveRecord::Base.sanitize_sql([parameritized_query, bind_variables])
  end

  private
  def bind_variables
    @options.slice(:minimum_pairing_frequency)
  end

  def parameritized_query
    <<~SQL
      SELECT a_root.name  AS root_name,
             a_other.name AS associated_artwork_name,
             count(*)     AS paired_frequency
      FROM merchandise_sales ms_root
        JOIN sales s                    ON ms_root.sale_id = s.id
        JOIN merchandise_sales ms_other ON ms_other.sale_id = s.id
        JOIN merchandises m_other       ON m_other.id = ms_other.merchandise_id
        JOIN merchandises m_root        ON m_root.id = ms_root.merchandise_id
        JOIN artworks a_root            ON a_root.id = m_root.artwork_id
        JOIN artworks a_other           ON a_other.id = m_other.artwork_id
        JOIN events event_sold_at       ON event_sold_at.id = s.event_id
      WHERE a_other.name <> a_root.name
        #{where_artwork_tag(:a_root)}
        #{where_artwork_tag(:a_other)}
        #{where_merchandise_tag(:m_root)}
        #{where_merchandise_tag(:m_other)}
        #{where_event_tag(:event_sold_at)}
        #{where_within_time_period}
      GROUP BY a_root.name, a_other.name
      #{having_minimum_pairing_frequency}
      ORDER BY root_name, paired_frequency DESC;
    SQL
  end

  def make_tag_filter(key, overloads)
    TagFilter.new(@options.fetch(key.to_sym, {}).merge(overloads))
  end

  def where_artwork_tag(name, prepend_with = :and)
    make_tag_filter("artwork_tag_filter_#{name}", on: name, prepend_with: prepend_with).to_sql
  end

  def where_merchandise_tag(name, prepend_with = :and)
    make_tag_filter("merchandise_tag_filter_#{name}", on: name, prepend_with: prepend_with).to_sql
  end

  def where_event_tag(name, prepend_with = :and)
    make_tag_filter(:event_tag_filter, on: name, prepend_with: prepend_with).to_sql
  end

  def where_within_time_period
    return
    # TODO
  end

  def having_minimum_pairing_frequency
    "HAVING count(*) >= :minimum_pairing_frequency"
  end

end
