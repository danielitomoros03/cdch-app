module SaberHelper
  MAX_AUTHORS = 6

  # Los autores tal como los escribe Saber; resalta el que se vinculó con la persona.
  def saber_authors(item, highlight: nil)
    names = item.author_names.first(MAX_AUTHORS).map do |name|
      name == highlight ? tag.strong(name) : name
    end
    names << "y #{item.author_names.size - MAX_AUTHORS} más" if item.author_names.size > MAX_AUTHORS
    safe_join(names, "; ")
  end
end
