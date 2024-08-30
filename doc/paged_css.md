## Paged CSS

Paged CSS is a subset of CSS designed for styling printed documents. It extends standard CSS to handle pagination, page sizes, headers, footers, and other aspects of printed content. Paged CSS is commonly used in scenarios where web content needs to be converted to PDFs or other paginated formats.

Setting page size

```css
@page {
  /* set a standard page size */
  size: A4 landscape;
  /* Custom */
  size: 8.5in 11in; /* Width x Height */
}
```

Setting page margins

```css
@page {
  margin: 1in; /* 1 inch on all sides */
  margin: 1in 0.5in 1in 0.5in; /* Top, Right, Bottom, Left */
}
```

Forcing a Page Break before or after an Element

```css
/* This ensures that every `h1` starts on a new page. */
h1 {
  page-break-before: always;
}
/* This ensures that every `p` element ends with a page break, starting the next content on a new page. */
p {
  page-break-after: always;
}
/* This prevents a table from being split across two pages. */
table {
  page-break-inside: avoid;
}
```

### Headers and Footers

When using Chromium-based rendering engines, headers and footers are not controlled by the Paged CSS standard but are instead managed through specific settings in the rendering engine.

With palapala PDF headers and footers are defined using `header_template` and `footer_template` options. These allow you to insert HTML content directly into the header or footer areas.

Critical is that you specify a font-size because by default Chrome uses a very tiny font.

```ruby
Palapala::Pdf.new(
  "<p>Hello world</>",
  header_template: '<div style="text-align: center; font-size: 12pt;">Page <span class="pageNumber"></span> of <span class="totalPages"></span></div>',
  footer_template: '<div style="text-align: center; font-size: 12pt;">Generated with Palapala PDF</div>',
).save("test.pdf")
```

### Examples

#### Headers and Footers

TODO explain about headers and footers, font sizes, styles being independent, and how to insert current page, total pages, etc.

#### Page sizes and margins

Paged CSS, also known as @page CSS, is used to control the layout and appearance of printed documents. It allows you to define page-specific styles, such as sizes and margins, which are crucial for generating well-formatted PDFs.

You can specify the size of the page using predefined sizes or custom dimensions. Common predefined sizes include A4, A3, letter, etc. Margins can be set for the top, right, bottom, and left sides of the page. You can specify all four margins at once or individually. You can also define named pages for different sections of your document.

##### Example: Different First Page

TODO Validate

```css
@page first {
  size: A4;
  margin: 2in; /* Larger margin for the first page */
}

@page {
  size: A4;
  margin: 1in;
}

body {
  counter-reset: page;
}

body:first {
  page: first;
}
```

#### Page breaks

Paged CSS allows you to control how content is divided across pages when printing or generating PDFs. Page breaks are an essential part of this, as they determine where a new page starts. You can control page breaks using the `page-break-before`, `page-break-after`, and `page-break-inside` properties.

##### Page Break Properties

1. **`page-break-before`**: Forces a page break before the element.
2. **`page-break-after`**: Forces a page break after the element.
3. **`page-break-inside`**: Prevents or allows a page break inside the element.

##### Values

- `auto`: Default. Neither forces nor prevents a page break.
- `always` Always forces a page break.
- `avoid`: Avoids a page break inside the element.
- `left`: Forces a page break so that the next page is a left page.
- `right`: Forces a page break so that the next page is a right page.

##### Examples

```css
/* This ensures that every `h1` starts on a new page. */
h1 {
  page-break-before: always;
}
/* This ensures that every `p` element ends with a page break, starting the next content on a new page. */
p {
  page-break-after: always;
}
/* This prevents a table from being split across two pages. */
table {
  page-break-inside: avoid;
}
```

##### Practical Use Cases

- **Chapter Titles**: Use `page-break-before: always;` for chapter titles to ensure each chapter starts on a new page.
- **Sections**: Use `page-break-after: always;` for sections that should end with a page break.
- **Tables and Figures**: Use `page-break-inside: avoid;` to keep tables and figures from being split across pages.

#### Tables accross Pages

TODO explain `display` property with the values `table-header-group` and `table-footer-group`

##### Example

```html
<table>
  <thead>
    <tr>
      <th>Header 1</th>
      <th>Header 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Data 1</td>
      <td>Data 2</td>
    </tr>
    <!-- More rows -->
  </tbody>
  <tfoot>
    <tr>
      <td>Footer 1</td>
      <td>Footer 2</td>
    </tr>
  </tfoot>
</table>
```

In this example:
- The `<thead>` section will be repeated at the top of each page.
- The `<tfoot>` section will be repeated at the bottom of each page.
