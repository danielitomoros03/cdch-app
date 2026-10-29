require "test_helper"

class PaginationHelperTest < ActionView::TestCase
  include WillPaginate::ActionView
  test "renders bootstrap 5 page items" do
    controller.request.path_parameters.merge!(controller: "dashboard/people", action: "index")
    collection = WillPaginate::Collection.new(2, 10, 45)

    render html: dashboard_pagination(collection)

    assert_select "nav[aria-label=Paginación] ul.pagination.pagination-sm"
    assert_select "li.page-item.active[aria-current=page] span.page-link", "2"
    assert_select "li.page-item a.page-link[rel=prev]", "1"
    assert_select "li.page-item a.page-link", text: "Siguiente ›"
  end
end
