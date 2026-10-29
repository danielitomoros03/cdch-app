require "will_paginate/view_helpers/action_view"

module PaginationHelper
  # Paginación con el marcado de Bootstrap 5 (page-item / page-link), en español.
  def dashboard_pagination(collection)
    will_paginate collection, renderer: Renderer, class: "pagination pagination-sm mb-0",
                              previous_label: "‹ Anterior", next_label: "Siguiente ›", inner_window: 2, outer_window: 0
  end

  class Renderer < WillPaginate::ActionView::LinkRenderer
    protected

    def html_container(html)
      tag(:nav, tag(:ul, html, class: @options[:class]), "aria-label": "Paginación")
    end

    def page_number(page)
      if page == current_page
        item(tag(:span, page, class: "page-link"), "active", "aria-current": "page")
      else
        item(link(page, page, class: "page-link", rel: rel_value(page)))
      end
    end

    def gap
      item(tag(:span, "&hellip;", class: "page-link"), "disabled")
    end

    def previous_or_next_page(page, text, _classname, aria_label = nil)
      if page
        item(link(text, page, class: "page-link", "aria-label": aria_label))
      else
        item(tag(:span, text, class: "page-link"), "disabled")
      end
    end

    private

    def item(content, state = nil, **attributes)
      tag(:li, content, class: [ "page-item", state ].compact.join(" "), **attributes)
    end
  end
end
