module DepartmentsHelper
  DEFAULT_DEPARTMENT_LOGO = "Logo-CDCH.png".freeze

  # Static logo for a department without an uploaded one: "<acronym>.png" in
  # app/assets/images, matched ignoring case ("Compras" finds "COMPRAS.png").
  # Falls back to the CDCH logo instead of raising when there is no file.
  def department_logo_asset(department)
    wanted = "#{department.acronym}.png"
    department_logo_files.find { |file| file.casecmp?(wanted) } || DEFAULT_DEPARTMENT_LOGO
  end

  private

  def department_logo_files
    @department_logo_files ||= Dir.children(Rails.root.join("app/assets/images"))
  end
end
