# Splits a relation into pages. An out-of-range page falls back to the
# nearest existing one, so a stale link never shows an error.
class Pagination
  PER_PAGE = 20

  attr_reader :page, :total_count

  def initialize(scope, page:, per_page: PER_PAGE)
    @scope = scope
    @per_page = per_page
    @total_count = scope.count
    @page = page.to_i.clamp(1, total_pages)
  end

  def records
    @scope.limit(@per_page).offset((page - 1) * @per_page)
  end

  def total_pages
    [ (total_count.to_f / @per_page).ceil, 1 ].max
  end

  def previous_page
    page - 1 if page > 1
  end

  def next_page
    page + 1 if page < total_pages
  end
end
