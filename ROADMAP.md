Models
 * artwork:
   * taggable
   * has many merchandise
 * merchandise:
   * released_at
   * belongs to artwork
 * transaction:
   * taggable
   * sale_price
   * list_price
   * sold_on: Date instead of DateTime
   * has many goods
 * expenses:
   * taggable
   * amount
 * event:
   * taggable
   * total_sales
   * started_at
   * ended_at
   * has many expenses
   * has many transactions

Concerns:
 * Taggable:
   * class method: tagged_with
   * helper method for DB migration
   * JSONB array column of tags

Controller:
 * EventTransactions
   * Bulk CSV File import
     * Wrap everything in DB transaction
     * Create event
     * Create transactions

Analytics:
 * Compare one merchandise against another
   * Scope each to specific event
   * Scope each to events by tag
 * Revenue over time
   * Scope by tag
   * Scope by merchandise tag
   * Comparable with other revenues over time
 * Distribution of sale prices
   * Distribution of transcation's sale_amounts
     * Comparable by specific events
     * Comparable by event's tags
   * Distribution of event's total_sales
     * Comparable via tags
  * Most common paired artworks/merchandise
    * Scoped to a specific event
    * Scoped to event's tag
