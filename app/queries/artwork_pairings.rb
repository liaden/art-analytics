# frozen_string_literal: true

class ArtworkPairings
  attr_accessor :options

  def initialize(options)
    @options = options
  end

  def run
    ActiveRecord::Base.connection.exec_query(to_sql).to_a
  end

  def to_sql
    ActiveRecord::Base.sanitize_sql([parameritized_query, bind_variables])
  end

  private

  def bind_variables
    @options.attributes.slice(:minimum_pairing_frequency, :date_after, :date_before)
  end

  def parameritized_query
    <<~SQL
      SELECT a_root.name  AS root_name,
             a_other.name AS associated_artwork_name,
             count(*)     AS paired_frequency
      FROM merchandise_sales ms_root
        JOIN sales s                    ON ms_root.sale_id = s.id
        JOIN merchandise_sales ms_other ON ms_other.sale_id = s.id
        JOIN merchandises m_other       ON m_other.id = ms_other.merchandise_id AND m_other.replaced_by_id IS NULL
        JOIN merchandises m_root        ON m_root.id = ms_root.merchandise_id   AND M_root.replaced_by_id  IS NULL
        JOIN artworks a_root            ON a_root.id = m_root.artwork_id
        JOIN artworks a_other           ON a_other.id = m_other.artwork_id
        JOIN events event_sold_at       ON event_sold_at.id = s.event_id
      WHERE
        -- prevent sales of single items from being paired with themselves
        NOT (ms_root.id = ms_other.id AND ms_root.quantity = 1)
        AND (a_root.replaced_by_id  IS NULL)
        AND (a_other.replaced_by_id IS NULL)
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

  def make_tag_filter(key)
    TagFilterFragment.new(@options.tag_filter_for(key))
  end

  def where_artwork_tag(name, prepend_with=:and)
    make_tag_filter("artwork_tag_filter_#{name}").to_sql(prepend_with)
  end

  def where_merchandise_tag(name, prepend_with=:and)
    make_tag_filter("merchandise_tag_filter_#{name}").to_sql(prepend_with)
  end

  def where_event_tag(_name, prepend_with=:and)
    make_tag_filter(:event_tag_filter).to_sql(prepend_with)
  end

  def where_within_time_period
    return unless @options.date_after and @options.date_before
    "AND event_sold_at.started_at BETWEEN :date_after AND :date_before"
  end

  def having_minimum_pairing_frequency
    "HAVING count(*) >= :minimum_pairing_frequency"
  end
end
