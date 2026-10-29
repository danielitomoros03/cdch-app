module DashboardHelper
  def sidebar_collapsed?
    cookies[:sidebar] == "collapsed"
  end

  # Enlace del menú lateral. `sections` son los controller_name que lo marcan activo.
  def sidebar_link(label, path, icon:, sections:)
    active = Array(sections).include?(controller_name)

    tag.li(class: "dashboard-nav__item") do
      link_to path, class: [ "dashboard-nav__link", { "is-active": active } ], title: label,
                    aria: { current: ("page" if active) }, data: { sidebar_target: "link" } do
        tag.i(class: "fas fa-fw #{icon}", aria: { hidden: true }) + tag.span(label, class: "dashboard-nav__label")
      end
    end
  end
end
