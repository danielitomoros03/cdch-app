module Cdch
  # Escribe un .xlsx de una hoja directamente sobre un ZipKit::Streamer, fila por fila,
  # para que la descarga empiece de inmediato y no se arme el archivo en memoria.
  # Formato: título, subtítulo, encabezado fijo con autofiltro y filas tipo cebra.
  #
  #   Cdch::XlsxWriter.new(zip, title: "...", subtitle: "...", columns: [ { header: "Nombre", width: 40 } ]).write do |sheet|
  #     sheet << [ "Ana", 3, Date.current ]
  #   end
  class XlsxWriter
    HEADER_ROW = 3

    # Índices de cellXfs en styles.xml: [normal, cebra] según el tipo de valor.
    STYLE = { title: 1, subtitle: 2, header: 3, text: [ 4, 5 ], number: [ 6, 7 ], date: [ 8, 9 ] }.freeze
    EXCEL_EPOCH = Date.new(1899, 12, 30)
    INVALID_XML = /[^\u0009\u000A\u000D -퟿-�]/

    def initialize(zip, title:, subtitle:, columns:, sheet_name: "Datos")
      @zip = zip
      @title = title
      @subtitle = subtitle
      @columns = columns
      @sheet_name = sheet_name
      @rows = 0
    end

    def write
      write_package_parts
      @zip.write_deflated_file("xl/worksheets/sheet1.xml") do |io|
        @io = io
        io << sheet_header
        io << row_xml(1, [ @title ], [ STYLE[:title] ])
        io << row_xml(2, [ @subtitle ], [ STYLE[:subtitle] ])
        io << row_xml(HEADER_ROW, @columns.map { |column| column[:header] }, [ STYLE[:header] ] * @columns.size, height: 30)
        yield self
        io << sheet_footer
      end
      @zip.write_deflated_file("xl/workbook.xml") { |io| io << workbook_xml }
    end

    def <<(values)
      @rows += 1
      zebra = @rows.even? ? 1 : 0
      styles = values.map { |value| STYLE.fetch(kind(value))[zebra] }
      @io << row_xml(HEADER_ROW + @rows, values, styles)
      self
    end

    private

    def kind(value)
      case value
      when Numeric then :number
      when Date then :date
      else :text
      end
    end

    def row_xml(number, values, styles, height: nil)
      cells = values.each_with_index.map { |value, index| cell_xml("#{column_letter(index)}#{number}", value, styles[index]) }
      %(<row r="#{number}"#{%( ht="#{height}" customHeight="1") if height}>#{cells.join}</row>)
    end

    def cell_xml(ref, value, style)
      case value
      when nil then %(<c r="#{ref}" s="#{style}"/>)
      when Numeric then %(<c r="#{ref}" s="#{style}"><v>#{value}</v></c>)
      when Date then %(<c r="#{ref}" s="#{style}"><v>#{(value - EXCEL_EPOCH).to_i}</v></c>)
      else %(<c r="#{ref}" s="#{style}" t="inlineStr"><is><t xml:space="preserve">#{escape(value)}</t></is></c>)
      end
    end

    def escape(value)
      value.to_s.gsub(INVALID_XML, "").encode(xml: :text)
    end

    def column_letter(index)
      letters = +""
      index += 1
      while index.positive?
        index, remainder = (index - 1).divmod(26)
        letters.prepend((65 + remainder).chr)
      end
      letters
    end

    def last_column = column_letter(@columns.size - 1)

    def filter_range = "A#{HEADER_ROW}:#{last_column}#{HEADER_ROW + [ @rows, 1 ].max}"

    def sheet_header
      cols = @columns.each_with_index.map { |column, index| %(<col min="#{index + 1}" max="#{index + 1}" width="#{column.fetch(:width, 14)}" customWidth="1"/>) }
      <<~XML.delete("\n")
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
        <sheetPr><pageSetUpPr fitToPage="1"/></sheetPr>
        <sheetViews><sheetView workbookViewId="0" showGridLines="0">
        <pane ySplit="#{HEADER_ROW}" topLeftCell="A#{HEADER_ROW + 1}" activePane="bottomLeft" state="frozen"/>
        </sheetView></sheetViews>
        <sheetFormatPr defaultRowHeight="16"/>
        <cols>#{cols.join}</cols>
        <sheetData>
      XML
    end

    def sheet_footer
      %(</sheetData><autoFilter ref="#{filter_range}"/><pageSetup orientation="landscape" fitToWidth="1" fitToHeight="0"/></worksheet>)
    end

    def workbook_xml
      <<~XML.delete("\n")
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
        <sheets><sheet name="#{escape(@sheet_name)}" sheetId="1" r:id="rId1"/></sheets>
        <definedNames><definedName name="_xlnm._FilterDatabase" localSheetId="0" hidden="1">'#{escape(@sheet_name)}'!$A$#{HEADER_ROW}:$#{last_column}$#{HEADER_ROW + [ @rows, 1 ].max}</definedName></definedNames>
        </workbook>
      XML
    end

    def write_package_parts
      @zip.write_deflated_file("[Content_Types].xml") { |io| io << CONTENT_TYPES }
      @zip.write_deflated_file("_rels/.rels") { |io| io << ROOT_RELS }
      @zip.write_deflated_file("xl/_rels/workbook.xml.rels") { |io| io << WORKBOOK_RELS }
      @zip.write_deflated_file("xl/styles.xml") { |io| io << STYLES }
    end

    CONTENT_TYPES = <<~XML.delete("\n").freeze
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
      <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
      <Default Extension="xml" ContentType="application/xml"/>
      <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
      <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
      <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
      </Types>
    XML

    ROOT_RELS = <<~XML.delete("\n").freeze
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
      <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
      </Relationships>
    XML

    WORKBOOK_RELS = <<~XML.delete("\n").freeze
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
      <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
      <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
      </Relationships>
    XML

    # Fuentes: 0 normal, 1 título, 2 subtítulo gris, 3 encabezado blanco en negrita.
    # Rellenos: 2 azul institucional (encabezado), 3 gris claro (cebra).
    # Estilos (cellXfs) en el orden de STYLE.
    STYLES = <<~XML.delete("\n").freeze
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
      <numFmts count="1"><numFmt numFmtId="164" formatCode="dd/mm/yyyy"/></numFmts>
      <fonts count="4">
      <font><sz val="10"/><color rgb="FF1F2937"/><name val="Calibri"/><family val="2"/></font>
      <font><b/><sz val="14"/><color rgb="FF082C95"/><name val="Calibri"/><family val="2"/></font>
      <font><i/><sz val="9"/><color rgb="FF6B7280"/><name val="Calibri"/><family val="2"/></font>
      <font><b/><sz val="10"/><color rgb="FFFFFFFF"/><name val="Calibri"/><family val="2"/></font>
      </fonts>
      <fills count="4">
      <fill><patternFill patternType="none"/></fill>
      <fill><patternFill patternType="gray125"/></fill>
      <fill><patternFill patternType="solid"><fgColor rgb="FF082C95"/><bgColor indexed="64"/></patternFill></fill>
      <fill><patternFill patternType="solid"><fgColor rgb="FFF1F4FA"/><bgColor indexed="64"/></patternFill></fill>
      </fills>
      <borders count="2">
      <border><left/><right/><top/><bottom/><diagonal/></border>
      <border><left/><right/><top/><bottom style="thin"><color rgb="FFE3E6F0"/></bottom><diagonal/></border>
      </borders>
      <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
      <cellXfs count="10">
      <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
      <xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>
      <xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1"/>
      <xf numFmtId="0" fontId="3" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1" applyAlignment="1"><alignment vertical="center" wrapText="1"/></xf>
      <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1"><alignment vertical="top"/></xf>
      <xf numFmtId="0" fontId="0" fillId="3" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="top"/></xf>
      <xf numFmtId="1" fontId="0" fillId="0" borderId="1" xfId="0" applyNumberFormat="1" applyBorder="1"/>
      <xf numFmtId="1" fontId="0" fillId="3" borderId="1" xfId="0" applyNumberFormat="1" applyFill="1" applyBorder="1"/>
      <xf numFmtId="164" fontId="0" fillId="0" borderId="1" xfId="0" applyNumberFormat="1" applyBorder="1" applyAlignment="1"><alignment horizontal="left"/></xf>
      <xf numFmtId="164" fontId="0" fillId="3" borderId="1" xfId="0" applyNumberFormat="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="left"/></xf>
      </cellXfs>
      <cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>
      </styleSheet>
    XML
  end
end
