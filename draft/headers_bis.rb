document = <<~HTML
<html>
<style>
  @page {
    margin: 0cm;
  }

  #content {
    font: 9pt sans-serif;
    line-height: 1.3;

    margin: 3cm;
    margin-top: 0cm;
    /* Avoid fixed header and footer to overlap page content */
    padding-top: 3cm;
    margin-bottom: 250px;
  }

  #header {
    position: fixed;
    top: 0cm;
    width: 100%;
    height: 100px;
    /* For testing */
    background: yellow;
    opacity: 0.5;
  }

  #footer {
    position: fixed;
    bottom: 0;
    width: 100%;
    height: 50px;
    font-size: 16pt;
    color: black;
    /* For testing */
    background: red;
    opacity: 0.5;
  }

  /* Print progressive page numbers */
  .page-number:after {
    counter-increment: page;
    content: "Page: " counter(page);
  }

</style>
<body>

  <header id="header">Header</header>

  <footer id="footer">footer
  <p>Page number: <span class="page-number">?</span></p>
  </footer>

  <div id="content">
    #{ "Here your long long content..." * 1000 }
    <p style="page-break-inside: avoid;">This text will not be broken between the pages</p>
  </div>

</body>
</html>
HTML

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "palapala"

Palapala::Pdf.new(
  document).save('headers_bis.pdf')

puts "Generated headers_bis.pdf"
`open headers_bis.pdf`
