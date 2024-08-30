# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "palapala"

long_text = (1..30).map { "Demonstrate a paragraph that is not split across pages." }.join(" ")

def table(rows)
  <<~HTML
  <table>
    <thead>
      <tr>
        <th>Header 1</th>
        <th>Header 2</th>
      </tr>
    </thead>
    <tbody>
    #{ (1..rows).map { |i| "<tr><td>Row #{i}, Cell 1</td><td>Row #{i}, Cell 2</td></tr>" }.join }
    </tbody>
    <tfoot>
      <tr>
        <td>Footer 1</td>
        <td>Footer 2</td>
      </tr>
    </tfoot>
  </table>
  HTML
end

big_table = table(35)
small_table = table(5)

document = <<~HTML
  <html>
    <style>
      @page {
        size: A4;
        margin: 2cm;
        margin-top: 3cm;
        margin-bottom: 3cm;
      }
      body, html {
        margin: 0;
        padding: 0;
        font-family: Arial, sans-serif;
      }
      h1 {
        page-break-before: always;
        border-bottom: 1px solid black;
      }
      h2 {
        /* keep with next */
        page-break-after: avoid;
      }
      @page:first {
        size: A4 landscape;
        margin: 0; /* no margin for the first page */
        padding: 0;
      }
      div.titlepage {
        background-color: black;
        color: white;
        font-size: 72pt;
        text-align: center;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100%;
        width: 100vw;
      }
      table {
        width: calc(100% - 1px);
        border-collapse: collapse;
        td, th {
          border: 1px solid black;
          padding: 0.5rem;
        }
        & thead, & tfoot {
          tr {
            background-color: lightgray;
            & th, & td {
              padding-top: 0.5rem;
              padding-bottom: 0.5rem;
            }
          }
        }
      }
      /* Initialize counters */
      body {
        counter-reset: h1Counter h2Counter;
      }
      /* Numbering for H1 elements */
      h1 {
        counter-increment: h1Counter;
        counter-reset: h2Counter; /* Reset h2 counter when a new h1 appears */
      }
      h1::before {
        content: counter(h1Counter) ". ";
        /* font-weight: bold; */
      }
      /* Numbering for H2 elements */
      h2 {
        counter-increment: h2Counter;
      }
      h2::before {
        content: counter(h1Counter) "." counter(h2Counter) " ";
        /* font-weight: bold; */
      }
    </style>
    <body>
      <div class="titlepage">
        <c-title>Title Page</c-title>
      </div>
      <h1>New Section</h1>
      <h2>Subsection tables</h2>
      <p>This demonstrates a table with a header and footer that spans multiple pages.</p>
      #{big_table}
      <h2>Subsection page break inside</h2>
      <p style="page-break-inside: avoid; text-align: justify">
        #{long_text}
      </p>
      <p>Note that the section title has moved to the second page because the paragraph above was moved to the second page.</p>
      <h1>New Section</h1>
      <p>Page 3 content</p>
      <p>A small table</p>
      #{small_table}
      <h2>Subsection</h2>
      <p>Some content</p>
      <h2>Subsection</h2>
      <p>Some content</p>
    </body>
  </html>
HTML

def debug(color: "red")
  <<~HTML
    <style>
      /* this is a class chrome assigns to the header, footer and content in the main template */
      #header, #content, #footer {
        border: 1px dotted #{color}; /* uncomment to see the areas */
      }
    </style>
  HTML
end

def header_footer_template(debug_color: nil)
  <<~HTML
  #{ debug(color: debug_color) if debug_color }
  <div style="text-align: center; font-size: 12pt; padding: 1rem; width: 100%;">#{yield}</div>
  HTML
end

footer_template = header_footer_template do
  "Page <span class='pageNumber'></span> of <span class='totalPages'></span>"
end

header_template = header_footer_template do
  "Generated with Palapala PDF"
end

Palapala::Pdf.new(document,
                  header_template:,
                  footer_template:).save("paged_css.pdf")

puts "Generated paged_css.pdf"

`open paged_css.pdf`
