// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}




#import "@preview/fontawesome:0.5.0": *

// This is an example typst template (based on the default template that ships
// with Quarto). It defines a typst function named 'article' which provides
// various customization options. This function is called from the 
// 'typst-show.typ' file (which maps Pandoc metadata function arguments)
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-show.typ' entirely. You can find 
// documentation on creating typst templates and some examples here: 
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates


// #let article(
//   title: none,
//   subtitle: none,
//   authors: none,
//   date: none,
//   abstract: none,
//   abstract-title: none,
//   cols: 1,
//   margin: (x: 1.25in, y: 1.25in),
//   paper: "us-letter",
//   lang: "en",
//   region: "US",
//   font: "libertinus serif",
//   fontsize: 11pt,
//   title-size: 1.5em,
//   subtitle-size: 1.25em,
//   heading-family: "libertinus serif",
//   heading-weight: "bold",
//   heading-style: "normal",
//   heading-color: black,
//   heading-line-height: 0.65em,
//   sectionnumbering: none,
//   pagenumbering: "1",
//   toc: false,
//   toc_title: none,
//   toc_depth: none,
//   toc_indent: 1.5em,
//   doc,
// ) = {
//   set page(
//     paper: paper,
//     margin: margin,
//     numbering: pagenumbering,
//   )
//   set par(justify: true)
//   set text(lang: lang,
//            region: region,
//            font: font,
//            size: fontsize)
//   set heading(numbering: sectionnumbering)
//   if title != none {
//     align(center)[#block(inset: 2em)[
//       #set par(leading: heading-line-height)
//       #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
//            or heading-color != black) {
//         set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
//         text(size: title-size)[#title]
//         if subtitle != none {
//           parbreak()
//           text(size: subtitle-size)[#subtitle]
//         }
//       } else {
//         text(weight: "bold", size: title-size)[#title]
//         if subtitle != none {
//           parbreak()
//           text(weight: "bold", size: subtitle-size)[#subtitle]
//         }
//       }
//     ]]
//   }

//   if authors != none {
//     let count = authors.len()
//     let ncols = calc.min(count, 3)
//     grid(
//       columns: (1fr,) * ncols,
//       row-gutter: 1.5em,
//       ..authors.map(author =>
//           align(center)[
//             #author.name \
//             #author.affiliation \
//             #author.email
//           ]
//       )
//     )
//   }

//   if date != none {
//     align(center)[#block(inset: 1em)[
//       #date
//     ]]
//   }

//   if abstract != none {
//     block(inset: 2em)[
//     #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
//     ]
//   }

//   if toc {
//     let title = if toc_title == none {
//       auto
//     } else {
//       toc_title
//     }
//     block(above: 0em, below: 2em)[
//     #outline(
//       title: toc_title,
//       depth: toc_depth,
//       indent: toc_indent
//     );
//     ]
//   }

//   if cols == 1 {
//     doc
//   } else {
//     columns(cols, doc)
//   }
// }

// #set table(
//   inset: 6pt,
//   stroke: none
// )




// CV Template with sidebar layout
// Left column: contact info, skills
// Right column: experience, education

// Global State for Timeline Configuration
#let timeline-config-state = state("timeline-config", (:))

// Timeline Section Wrapper
// levels: tuple of heading levels that should receive dots (e.g., (3,) or (3,4,5))
#let timeline-section(levels: (1,2,3,4,5,6), body) = {
  context {
     let config = timeline-config-state.get()
     // Ensure we have defaults if config is empty (fallback)
     let dot-size = config.at("dot-size", default: 2pt)
     let line-width = config.at("line-width", default: 1pt)
     let dot-color = config.at("dot-color", default: rgb("#2563eb"))
     let line-color = config.at("line-color", default: rgb("#e2e8f0"))
     
     // Use fixed pt values for horizontal positioning
     let inset-left = 15pt  // Fixed inset value
     let dot-dx = -inset-left - dot-size  // Center dot on line
     
     let user-dy = config.at("dy", default: 0pt)

     let add-dot(it) = {
       block([
         #place(left + horizon, dx: dot-dx, dy: user-dy, circle(radius: dot-size, fill: dot-color))
         #it
       ])
     }

     pad(left: 1em, block(
       width: 100%,
       inset: (left: inset-left),
       stroke: (left: line-width + line-color),
       breakable: true
     )[
       #show heading.where(level: 1): it => if 1 in levels {
         block([#place(left + horizon, dx: dot-dx, dy: user-dy, circle(radius: dot-size, fill: dot-color)) #it])
       } else { it }
       #show heading.where(level: 2): it => if 2 in levels { add-dot(it) } else { it }
       #show heading.where(level: 3): it => if 3 in levels { add-dot(it) } else { it }
       #show heading.where(level: 4): it => if 4 in levels { add-dot(it) } else { it }
       #show heading.where(level: 5): it => if 5 in levels { add-dot(it) } else { it }
       #show heading.where(level: 6): it => if 6 in levels { add-dot(it) } else { it }
       #body
     ])
  }
}
 
#let cv(
  title: none,
  subtitle: none,
  // Sidebar data block (grouped contact info)
  sidebar: none,
  // Legacy individual params (for backwards compatibility)
  photo: none,
  phone: none,
  email: none,
  birthdate: none,
  city: none,
  nationality: none,
  website: none,
  permit: none,
  linkedin: none,
  github: none,
  date: none,
  date-prefix: "Last updated: ",
  // Manual customization parameters
  sidebar-styles: none,
  sidebar-defaults: none, // Global default styles
  sidebar-sections: none, // Unified modular sections
  section-order: ("photo", "contact", "networks", "skills", "languages", "strengths", "interests"),
  layout-config: none,
  theme: none,
  // Header block: name, title, objective — all optional, colors auto-inherit from theme
  cv-header: none,
  body
) = {
  // Helper to get sidebar data (from sidebar block or legacy params)
  let get-sidebar-data(key) = {
    if sidebar != none and key in sidebar { sidebar.at(key) }
    else if key == "photo" { photo }
    else if key == "phone" { phone }
    else if key == "email" { email }
    else if key == "birthdate" { birthdate }
    else if key == "city" { city }
    else if key == "nationality" { nationality }
    else if key == "website" { website }
    else if key == "permit" { permit }
    else if key == "linkedin" { linkedin }
    else if key == "github" { github }
    else { none }
  }

  // Theme setup
  let default-theme = (
    main-font: "Inter",
    title-font: "Inter",  // Global font for section titles
    text-font: "Inter",   // Global font for body text
    sidebar: (
      title-color: rgb("#2563eb"),       // section titles
      text-color: rgb("#1e293b"),        // plain text, bullet names, key labels
      accent-color: rgb("#64748b"),      // values, sub-items, secondary text
      link-color: rgb("#2563eb"),        // phone, email, linkedin, github, website
      icon-color: rgb("#2563eb"),        // SVG icons (defaults to title-color if omitted)
      photo-border-color: rgb("#2563eb"), // photo border stroke
      title-size: 11pt,
      text-size: 9pt,
    ),
    main: (
      title-color: rgb("#2563eb"),
      subtitle-color: rgb("#1e293b"),
      text-color: rgb("#1e293b"),
      // link-color: none by default - allows manual inline colors to work
    ),
    headings: (
      h1: 14pt,
      h2: 11pt,
      h3: 10pt,
      h4: 9pt,
      h5-h6: 8pt,
      normal: 10pt,
    ),
    header: (:),  // theme-level cv-header color overrides
  )

  let col(c) = if type(c) == color { c } else { rgb(c) }
  let sz(s) = if type(s) == length { s } else { float(str(s).replace("pt", "")) * 1pt }

  let current-theme = {
    let base = default-theme
    if theme != none {
      if "main-font" in theme { base.main-font = theme.main-font }
      if "title-font" in theme { base.title-font = theme.title-font }
      if "text-font" in theme { base.text-font = theme.text-font }
      
      if "sidebar" in theme {
        if "title-color" in theme.sidebar { base.sidebar.title-color = col(theme.sidebar.title-color) }
        if "text-color" in theme.sidebar { base.sidebar.text-color = col(theme.sidebar.text-color) }
        if "accent-color" in theme.sidebar { base.sidebar.accent-color = col(theme.sidebar.accent-color) }
        if "link-color" in theme.sidebar { base.sidebar.link-color = col(theme.sidebar.link-color) }
        if "icon-color" in theme.sidebar { base.sidebar.icon-color = col(theme.sidebar.icon-color) }
        if "photo-border-color" in theme.sidebar { base.sidebar.photo-border-color = col(theme.sidebar.photo-border-color) }

        // Check for font sizes in sidebar (often in sidebar-defaults in YAML but can be mapped here)
        if "title-size" in theme.sidebar { base.sidebar.title-size = sz(theme.sidebar.title-size) }
        if "text-size" in theme.sidebar { base.sidebar.text-size = sz(theme.sidebar.text-size) }
      }
      
      if "main" in theme {
        if "title-color" in theme.main { base.main.title-color = col(theme.main.title-color) }
        if "subtitle-color" in theme.main { base.main.subtitle-color = col(theme.main.subtitle-color) }
        if "text-color" in theme.main { base.main.text-color = col(theme.main.text-color) }
        // Only set link-color if explicitly provided and not "none"
        if "link-color" in theme.main {
          let lc = theme.main.link-color
          if lc != "none" and lc != none { 
            base.main.insert("link-color", col(lc))
          }
        }
      }
      
      if "headings" in theme {
        if "h1" in theme.headings { base.headings.h1 = sz(theme.headings.h1) }
        if "h2" in theme.headings { base.headings.h2 = sz(theme.headings.h2) }
        if "h3" in theme.headings { base.headings.h3 = sz(theme.headings.h3) }
        if "h4" in theme.headings { base.headings.h4 = sz(theme.headings.h4) }
        if "h5-h6" in theme.headings { base.headings.at("h5-h6") = sz(theme.headings.at("h5-h6")) }
        if "normal" in theme.headings { base.headings.normal = sz(theme.headings.normal) }
      }

      if "header" in theme {
        if "name-color" in theme.header { base.header.insert("name-color", col(theme.header.name-color)) }
        if "title-color" in theme.header { base.header.insert("title-color", col(theme.header.title-color)) }
        if "objective-bg" in theme.header { base.header.insert("objective-bg", col(theme.header.objective-bg)) }
        if "objective-stroke-color" in theme.header { base.header.insert("objective-stroke-color", col(theme.header.objective-stroke-color)) }
        if "objective-stroke-width" in theme.header { base.header.insert("objective-stroke-width", sz(theme.header.objective-stroke-width)) }
      }
    }
    // Backward compatibility: override from sidebar-defaults param if present
    if sidebar-defaults != none {
       if "title-size" in sidebar-defaults { base.sidebar.title-size = sz(sidebar-defaults.at("title-size")) }
       if "text-size" in sidebar-defaults { base.sidebar.text-size = sz(sidebar-defaults.at("text-size")) }
    }
    base
  }

  // Page setup
  let default-margins = (top: 1.5cm, bottom: 1.5cm, left: 1cm, right: 1cm)
  let margins = if layout-config != none and "margins" in layout-config {
    layout-config.margins
  } else {
    default-margins
  }

  set page(
    paper: "a4",
    margin: 0cm, // Full bleed for backgrounds
  )
  
  // Typography
  set text(font: current-theme.main-font, size: 10pt, fill: current-theme.main.text-color)
  set par(justify: true, leading: 0.65em)
  
  


  // Helper to generate sidebar content with dynamic spacing
  let make-sidebar(auto-spacing) = {
    
    // Build style with clear hierarchy:
    // 1. Base defaults (from auto-spacing)
    // 2. sidebar-defaults (global overrides)
    // 3. section.style (per-section overrides)
    let get-style(section-id, section-style) = {
      // Base style with sensible defaults
      let base = (
        // Typography - Fonts
        title-font: current-theme.title-font,  // Font for section titles
        text-font: current-theme.text-font,    // Font for normal text
        
        // Typography - Sizes
        text-size: auto-spacing.text-size,
        title-size: auto-spacing.title,
        icon-size: 12pt,
        
        // Category/items styling (for skills-like sections)
        category-size: auto-spacing.text-size,
        category-weight: "semibold",
        category-color: current-theme.sidebar.text-color,
        item-color: current-theme.sidebar.accent-color,
        subitem-color: current-theme.sidebar.accent-color,
        
        // Spacing - well-defined hierarchy
        title-after: 0.15em,           // Space after section title
        item-after: auto-spacing.item, // Space after each item
        section-after: auto-spacing.section, // Space after entire section
      )
      
      // Merge global defaults
      let global-defaults = if sidebar-defaults != none { sidebar-defaults } else { (:) }
      
      // Merge section-specific style
      let section-overrides = if section-style != none { section-style } else { (:) }
      
      // Final merge: base < global < section
      base + global-defaults + section-overrides
    }
    
    // Item renderers by type - returns content for a specific item type
    let render-typed-item(item-type, style) = {
      // SVG icons injected by icons.lua filter at render time
      let icon-map = (
        phone: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"#2563eb\" viewBox=\"0 0 16 16\">\n  <path d=\"M3.654 1.328a.678.678 0 0 0-1.015-.063L1.605 2.3c-.483.484-.661 1.169-.45 1.77a17.6 17.6 0 0 0 4.168 6.608 17.6 17.6 0 0 0 6.608 4.168c.601.211 1.286.033 1.77-.45l1.034-1.034a.678.678 0 0 0-.063-1.015l-2.307-1.794a.68.68 0 0 0-.58-.122l-2.19.547a1.75 1.75 0 0 1-1.657-.459L5.482 8.062a1.75 1.75 0 0 1-.46-1.657l.548-2.19a.68.68 0 0 0-.122-.58zM1.884.511a1.745 1.745 0 0 1 2.612.163L6.29 2.98c.329.423.445.974.315 1.494l-.547 2.19a.68.68 0 0 0 .178.643l2.457 2.457a.68.68 0 0 0 .644.178l2.189-.547a1.75 1.75 0 0 1 1.494.315l2.306 1.794c.829.645.905 1.87.163 2.611l-1.034 1.034c-.74.74-1.846 1.065-2.877.702a18.6 18.6 0 0 1-7.01-4.42 18.6 18.6 0 0 1-4.42-7.009c-.362-1.03-.037-2.137.703-2.877z\"/>\n</svg>\n",
        email: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"#2563eb\" viewBox=\"0 0 16 16\">\n  <path d=\"M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2zm2-1a1 1 0 0 0-1 1v.217l7 4.2 7-4.2V4a1 1 0 0 0-1-1zm13 2.383-4.708 2.825L15 11.105zm-.034 6.876-5.64-3.471L8 9.583l-1.326-.795-5.64 3.47A1 1 0 0 0 2 13h12a1 1 0 0 0 .966-.741M1 11.105l4.708-2.897L1 5.383z\"/>\n</svg>\n",
        birthdate: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" viewBox=\"0 0 16 16\">\n  <path d=\"M11 6.5a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5z\"/>\n  <path d=\"M3.5 0a.5.5 0 0 1 .5.5V1h8V.5a.5.5 0 0 1 1 0V1h1a2 2 0 0 1 2 2v11a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2h1V.5a.5.5 0 0 1 .5-.5M1 4v10a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V4z\"/>\n</svg>\n",
        city: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"#2563eb\" viewBox=\"0 0 16 16\">\n  <path d=\"M8 16s6-5.686 6-10A6 6 0 0 0 2 6c0 4.314 6 10 6 10m0-7a3 3 0 1 1 0-6 3 3 0 0 1 0 6\"/>\n</svg>\n",
        nationality: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" viewBox=\"0 0 16 16\">\n  <path d=\"M14.778.085A.5.5 0 0 1 15 .5V8a.5.5 0 0 1-.314.464L14.5 8l.186.464-.003.001-.006.003-.023.009a12 12 0 0 1-.397.15c-.264.095-.631.223-1.047.35-.816.252-1.879.523-2.71.523-.847 0-1.548-.28-2.158-.525l-.028-.01C7.68 8.71 7.14 8.5 6.5 8.5c-.7 0-1.638.23-2.437.477A20 20 0 0 0 3 9.342V15.5a.5.5 0 0 1-1 0V.5a.5.5 0 0 1 1 0v.282c.226-.079.496-.17.79-.26C4.606.272 5.67 0 6.5 0c.84 0 1.524.277 2.121.519l.043.018C9.286.788 9.828 1 10.5 1c.7 0 1.638-.23 2.437-.477a20 20 0 0 0 1.349-.476l.019-.007.004-.002h.001M14 1.221c-.22.078-.48.167-.766.255-.81.252-1.872.523-2.734.523-.886 0-1.592-.286-2.203-.534l-.008-.003C7.662 1.21 7.139 1 6.5 1c-.669 0-1.606.229-2.415.478A21 21 0 0 0 3 1.845v6.433c.22-.078.48-.167.766-.255C4.576 7.77 5.638 7.5 6.5 7.5c.847 0 1.548.28 2.158.525l.028.01C9.32 8.29 9.86 8.5 10.5 8.5c.668 0 1.606-.229 2.415-.478A21 21 0 0 0 14 7.655V1.222z\"/>\n</svg>\n",
        permit: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" viewBox=\"0 0 16 16\">\n  <path d=\"M5 8a2 2 0 1 0 0-4 2 2 0 0 0 0 4m4-2.5a.5.5 0 0 1 .5-.5h4a.5.5 0 0 1 0 1h-4a.5.5 0 0 1-.5-.5M9 8a.5.5 0 0 1 .5-.5h4a.5.5 0 0 1 0 1h-4A.5.5 0 0 1 9 8m1 2.5a.5.5 0 0 1 .5-.5h3a.5.5 0 0 1 0 1h-3a.5.5 0 0 1-.5-.5\"/>\n  <path d=\"M2 2a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2zM1 4a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H8.96q.04-.245.04-.5C9 10.567 7.21 9 5 9c-2.086 0-3.8 1.398-3.984 3.181A1 1 0 0 1 1 12z\"/>\n</svg>\n",
        website: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" viewBox=\"0 0 16 16\">\n  <path d=\"M4.715 6.542 3.343 7.914a3 3 0 1 0 4.243 4.243l1.828-1.829A3 3 0 0 0 8.586 5.5L8 6.086a1 1 0 0 0-.154.199 2 2 0 0 1 .861 3.337L6.88 11.45a2 2 0 1 1-2.83-2.83l.793-.792a4 4 0 0 1-.128-1.287z\"/>\n  <path d=\"M6.586 4.672A3 3 0 0 0 7.414 9.5l.775-.776a2 2 0 0 1-.896-3.346L9.12 3.55a2 2 0 1 1 2.83 2.83l-.793.792c.112.42.155.855.128 1.287l1.372-1.372a3 3 0 1 0-4.243-4.243z\"/>\n</svg>\n",
        linkedin: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"#2563eb\" viewBox=\"0 0 16 16\">\n  <path d=\"M0 1.146C0 .513.526 0 1.175 0h13.65C15.474 0 16 .513 16 1.146v13.708c0 .633-.526 1.146-1.175 1.146H1.175C.526 16 0 15.487 0 14.854zm4.943 12.248V6.169H2.542v7.225zm-1.2-8.212c.837 0 1.358-.554 1.358-1.248-.015-.709-.52-1.248-1.342-1.248S2.4 3.226 2.4 3.934c0 .694.521 1.248 1.327 1.248zm4.908 8.212V9.359c0-.216.016-.432.08-.586.173-.431.568-.878 1.232-.878.869 0 1.216.662 1.216 1.634v3.865h2.401V9.25c0-2.22-1.184-3.252-2.764-3.252-1.274 0-1.845.7-2.165 1.193v.025h-.016l.016-.025V6.169h-2.4c.03.678 0 7.225 0 7.225z\"/>\n</svg>\n",
        github: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"#2563eb\" viewBox=\"0 0 16 16\">\n  <path d=\"M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27s1.36.09 2 .27c1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8\"/>\n</svg>\n",
      )
      let icon-data = icon-map.at(item-type, default: none)

      let content-val = get-sidebar-data(item-type)

      if content-val != none and content-val != "" and icon-data != none {
        
        // Determine icon color: use style.icon-color if set (per-section override), otherwise theme icon-color
        let target-color = style.at("icon-color", default: current-theme.sidebar.icon-color)
        let icon-color-hex = target-color.to-hex()
        
        // Use regex to replace ANY fill attribute (currentColor, #hex, etc.) with the target color
        // This ensures fully consistent coloring even for icons with hardcoded colors
        let colorized-icon = icon-data.replace(regex("fill=\"[^\"]*\""), "fill=\"" + icon-color-hex + "\"")
        
        grid(
          columns: (16pt, 1fr),
          column-gutter: 6pt,
          rows: (auto,),
          align: (center + horizon, left + horizon),
          box(height: 12pt, width: 12pt)[
            #set align(center + horizon)
            #image(bytes(colorized-icon), format: "svg", width: style.icon-size)
          ],
          {
            // Special handling for links
            if item-type == "phone" {
              text(font: style.text-font, size: style.text-size, fill: current-theme.sidebar.link-color)[#link("tel:" + content-val)[#content-val]]
            } else if item-type == "email" {
              text(font: style.text-font, size: style.text-size, fill: current-theme.sidebar.link-color)[#link("mailto:" + content-val)[#content-val]]
            } else if item-type in ("website", "linkedin", "github") {
              let display-val = get-sidebar-data(item-type + "-display")
              let default-label = if item-type == "linkedin" { "LinkedIn" } else if item-type == "github" { "GitHub" } else if item-type == "website" { content-val.replace("https://", "").replace("http://", "") } else { content-val }
              let label = if display-val != none { display-val } else { default-label }
              text(font: style.text-font, size: style.text-size, fill: current-theme.sidebar.link-color)[#link(content-val)[#label]]
            } else {
              text(font: style.text-font, size: style.text-size, fill: current-theme.sidebar.text-color)[#content-val]
            }
          }
        )
      }
    }

    // Section Renderers (only photo is special, others use custom renderer)
    let renderers = (
      photo: (style) => {
        v(style.at("section-before", default: 0pt))
        let size = style.at("photo-size", default: 80pt)
        let radius = style.at("photo-radius", default: 50%)
        // photo-border: true/false, photo-border-width: thickness
        let show-border = style.at("photo-border", default: true)
        let border-width = style.at("photo-border-width", default: 2pt)
        let stroke-val = if show-border { border-width + current-theme.sidebar.photo-border-color } else { none }
        let photo-val = get-sidebar-data("photo")
        if photo-val != none and photo-val != "" {
          block(width: 100%)[
            #align(center)[
              #box(
                width: size,
                height: size,
                radius: radius,
                clip: true,
                stroke: stroke-val,
              )[
                #image(photo-val, width: size, height: size, fit: "cover")
              ]
            ]
          ]
          v(style.at("section-after", default: 0.5em))
        }
      },
    )

    // Generic renderer for custom sections - supports all item formats
    let render-custom-section(section, style) = {
      v(style.at("section-before", default: 0pt))
      let has-title = "title" in section and section.title != ""

      // Direct title rendering with explicit zero paragraph spacing
      if has-title {
        block(above: 0pt, below: style.at("title-after", default: 0.1em))[
          #text(font: style.title-font, size: style.title-size, weight: "bold", fill: current-theme.sidebar.title-color)[#section.title]
        ]
      }
      
      set text(font: style.text-font, size: style.text-size)
      set block(above: 0pt, below: 0pt)
      
      let item-gap = style.at("item-after", default: 0pt)
      
      if "items" in section and section.items != none {
        // Prepare all items first
        let items-content = section.items.map(item => {
          if type(item) == dictionary {
            if "type" in item {
              // Typed item now returns content directly
              render-typed-item(item.type, style)
            } else if "category" in item {
              // Category + items format
              let cat-size = style.at("category-size", default: style.text-size)
              let cat-color = style.at("category-color", default: current-theme.sidebar.text-color)
              let cat-weight = style.at("category-weight", default: "semibold")
              let item-color = style.at("item-color", default: current-theme.sidebar.accent-color)
              
              box[
                #text(font: style.text-font, size: cat-size, weight: cat-weight, fill: cat-color)[#item.category]
                #linebreak()
                #if "items" in item and item.items != "" {
                  text(font: style.text-font, fill: item-color)[#item.items]
                }
              ]
            } else if "name" in item {
              // Name + value OR name + subitems format
              let item-color = style.at("item-color", default: current-theme.sidebar.accent-color)
              let subitem-color = style.at("subitem-color", default: current-theme.sidebar.accent-color)

              if "subitems" in item and item.subitems != none {
                // Name + subitems
                box[
                  #text(font: style.text-font, fill: current-theme.sidebar.text-color)[• #item.name]
                  #for subitem in item.subitems {
                    linebreak()
                    h(0.8em)
                    text(font: style.text-font, fill: subitem-color)[◦ #subitem]
                  }
                ]
              } else if "value" in item and item.value != "" {
                // Name : value
                box[#text(font: style.text-font, weight: "semibold", fill: current-theme.sidebar.text-color)[#item.name] : #text(font: style.text-font, fill: item-color)[#item.value]]
              } else {
                // Just name
                text(font: style.text-font, fill: current-theme.sidebar.text-color)[• #item.name]
              }
            } else { none }
          } else if item != "" {
            // Simple list format
            text(font: style.text-font, fill: current-theme.sidebar.text-color)[• #item]
          } else { none }
        }).filter(x => x != none)
        
        // Render all with stack to control spacing precisely
        if items-content.len() > 0 {
          stack(dir: ttb, spacing: item-gap, ..items-content)
        }
      } else if "content" in section and section.content != "" {
        // Text block format
        text(fill: current-theme.sidebar.text-color)[#section.content]
      }
      
      v(style.at("section-after", default: 0.3em))
    }

    // Determine sections to render
    let sections-to-render = if sidebar-sections != none {
      sidebar-sections
    } else {
      // Fallback to section-order for backwards compatibility
      section-order.map(name => (id: name))
    }

    // Render loop
    for section in sections-to-render {
      let section-id = if type(section) == dictionary { section.at("id", default: "") } else { section }
      let section-style = if type(section) == dictionary { section.at("style", default: none) } else { none }
      let style = get-style(section-id, section-style)
      
      if section-id in renderers {
        // Use predefined renderer (only photo)
        (renderers.at(section-id))(style)
      } else if type(section) == dictionary and ("title" in section or "items" in section) {
        // Use custom section renderer
        render-custom-section(section, style)
      }
    }
  }

  // Generate layouts
  layout(size => {
    let avail-height = size.height
    
    // Layout Calculation
    let sidebar-width = if layout-config != none and "sidebar-width" in layout-config { layout-config.sidebar-width } else { 1fr }
    let main-width = if layout-config != none and "main-width" in layout-config { layout-config.main-width } else { 2.5fr }
    let gutter-width = if layout-config != none and "gutter" in layout-config { layout-config.gutter } else { 1cm }
    
    // Background colors
    let sidebar-bg = if layout-config != none and "sidebar-bg" in layout-config { layout-config.sidebar-bg } else { none }
    let main-bg = if layout-config != none and "main-bg" in layout-config { layout-config.main-bg } else { none }

    // Timeline Configuration
    let timeline-dx = if layout-config != none and "timeline" in layout-config and "dx" in layout-config.timeline { layout-config.timeline.dx } else { -1.7em }
    let timeline-dy = if layout-config != none and "timeline" in layout-config and "dy" in layout-config.timeline { layout-config.timeline.dy } else { 0pt }
    
    // Advanced Timeline Style
    let dot-size = if layout-config != none and "timeline" in layout-config and "dot-size" in layout-config.timeline { layout-config.timeline.dot-size } else { 2pt }
    let line-width = if layout-config != none and "timeline" in layout-config and "line-width" in layout-config.timeline { layout-config.timeline.line-width } else { 1pt }
    let dot-color = if layout-config != none and "timeline" in layout-config and "dot-color" in layout-config.timeline { layout-config.timeline.dot-color } else { current-theme.main.title-color }
    let line-color = if layout-config != none and "timeline" in layout-config and "line-color" in layout-config.timeline { layout-config.timeline.line-color } else { rgb("#e2e8f0") }

    // Content Height correction (full bleed page means avail-height includes margins)
    let content-avail-height = avail-height - margins.top - margins.bottom

    // Fixed spacing configuration (equivalent to "normal")
    let spacing-config = (
      section: 0.6em, 
      item: 0.4em, 
      title: 11pt, 
      text-size: 9pt
    )
       
    // Update global state with timeline config
    timeline-config-state.update((
        dx: timeline-dx,
        dy: timeline-dy,
        dot-size: dot-size,
        line-width: line-width,
        dot-color: dot-color,
        line-color: line-color
    ))

    // Final Layout rendering
    grid(
       columns: (sidebar-width, main-width),
       column-gutter: 0pt, // Gutter handled by padding
       fill: (x, y) => {
         if x == 0 and sidebar-bg != none { sidebar-bg }
         else if x == 1 and main-bg != none { main-bg }
         else { none }
       },
       
       // LEFT SIDEBAR
       block(
         width: 100%, 
         height: 100%,
         inset: (
             top: margins.top, 
             bottom: margins.bottom, 
             left: margins.left, 
             right: margins.left // Force centering in sidebar
         ),
       )[
         #set text(font: current-theme.main-font)
         #show link: it => { set text(fill: current-theme.sidebar.link-color); it }
         #make-sidebar(spacing-config)
       ],
       
       // RIGHT MAIN CONTENT
       block(
         width: 100%, 
         height: 100%,
         inset: (
             top: margins.top, 
             bottom: margins.bottom, 
             right: margins.right, 
             left: gutter-width / 2
         ),
         {
          // Main body styles
          // Only apply default link color if it is set in the theme; otherwise inherited
           let main-link-color = current-theme.main.at("link-color", default: none)
           if main-link-color != none {
             show link: it => { set text(fill: main-link-color); it }
           }
          show heading.where(level: 1): it => {
            set text(size: current-theme.headings.h1, weight: "bold", fill: current-theme.main.title-color)
            v(0.5em)
            it
            v(0.3em)
            v(0.3em)
          }
          
          // H2 Style (Section Titles - Normal)
          show heading.where(level: 2): it => {
            set text(size: current-theme.headings.h2, weight: "semibold", fill: current-theme.main.subtitle-color)
            v(0.5em)
            it
            v(0.3em)
          }
          
          // H3 Style (Job Entries - Normal No Dots globally)
          show heading.where(level: 3): it => {
            set text(size: current-theme.headings.h3, weight: "medium", fill: rgb("#475569"))
            it
          }

          // H4-H6 styles using flexible sizing
          show heading.where(level: 4): it => { set text(size: current-theme.headings.h4); it }
          show heading: it => {
            if it.level > 4 { 
               set text(size: current-theme.headings.at("h5-h6")); it 
            } else { it }
          }
          
          // Set base text size
          set text(size: current-theme.headings.normal, fill: current-theme.main.text-color)

          // Render cv-header (name / title / objective) if defined in metadata
          // Fallback chain for each color:
          //   1. explicit cv-header.* override  (per-document)
          //   2. cv-theme.header.*              (per-theme)
          //   3. computed defaults              (from active theme colors)
          if cv-header != none {
            let hx(key) = cv-header.at(key, default: none)
            let th = current-theme.header

            let hcol(key, theme-key, fallback) = {
              if hx(key) != none { rgb(hx(key).replace("\#", "#")) }
              else if theme-key in th { th.at(theme-key) }
              else { fallback }
            }
            let hsz(key, theme-key, fallback) = {
              if hx(key) != none { eval(hx(key)) }
              else if theme-key in th { th.at(theme-key) }
              else { fallback }
            }

            let h-name-color  = hcol("name-color",  "name-color",  current-theme.main.text-color)
            let h-title-color = hcol("title-color", "title-color", current-theme.main.title-color)
            let h-obj-bg      = hcol("objective-bg", "objective-bg",
              if layout-config != none and "sidebar-bg" in layout-config { layout-config.sidebar-bg }
              else { rgb("#f1f5f9") }
            )
            let h-stroke-color  = hcol("objective-stroke-color", "objective-stroke-color", current-theme.main.title-color)
            let h-stroke-width  = hsz("objective-stroke-width",  "objective-stroke-width", 2pt)
            let h-name-size     = hsz("name-size",  "name-size",  14pt)
            let h-title-size    = hsz("title-size", "title-size", 18pt)

            if hx("name") != none and hx("name") != "" {
              text(size: h-name-size, weight: "bold", fill: h-name-color)[#hx("name")]
              v(0.15em)
            }
            if hx("title") != none and hx("title") != "" {
              text(size: h-title-size, weight: "bold", fill: h-title-color)[#hx("title")]
              v(0.5em)
            }
            if hx("objective") != none and hx("objective") != "" {
              block(
                fill: h-obj-bg, inset: 8pt, radius: 4pt,
                stroke: h-stroke-width + h-stroke-color, width: 100%,
              )[#text(fill: current-theme.main.text-color)[#hx("objective")]]
              v(0.5em)
            }
          }

          body
         
         if date != none and date != "" {
           v(1fr)
           align(center)[
             #text(size: 8pt, fill: rgb("#94a3b8"))[
               #date-prefix #date
             ]
           ]
         }
       }
    )
    )
  })
}

#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "a4",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: doc => cv(
  title: "CV - Marie Dupont",
  subtitle: "",
  // Sidebar data block
  sidebar: (
    "photo": "../assets/img/image.png",
    "phone": "+33 6 12 34 56 78",
    "email": "marie.dupont\@example.com".replace("\@", "@"),
    "birthdate": "15/03/1995",
    "city": "Paris, France",
    "nationality": "French",
    "website": "https:\/\/mariedupont.dev".replace("\/", "/"),
    "website-display": "mariedupont.dev".replace("\@", "@"),
    "permit": "Driving License B",
    "linkedin": "https:\/\/linkedin.com/in/marie-dupont".replace("\/", "/"),
    "linkedin-display": "\@marie-dupont".replace("\@", "@"),
    "github": "https:\/\/github.com/mdupont".replace("\/", "/"),
    "github-display": "\@mdupont".replace("\@", "@"),
  ),
  // Legacy individual params (backwards compatibility)
  photo: none,
  phone: "",
  email: "",
  birthdate: "",
  city: "",
  nationality: "",
  website: none,
  permit: "",
  linkedin: none,
  github: none,
  sidebar-styles: (
    "global": (
      "__is_style": true,
      
      
      
      
      
      
      
    ),
    "contact": (
      "__is_style": true,
      
      
      
      
      
    ),
    "networks": (
      "__is_style": true,
      
      
      
      
      
    ),
    "skills": (
      "__is_style": true,
      
      
      
      
      
    ),
    "languages": (
      "__is_style": true,
      
      
      
      
      
    ),
    "strengths": (
      "__is_style": true,
      
      
      
      
      
    ),
    "interests": (
      "__is_style": true,
      
      
      
      
      
    ),
    "photo": (
      "__is_style": true,
      
      
      
      
      
      
      
    ),
  ),
  sidebar-sections: (
      (
      id: "photo",
      
            
            style: (
        
        
        
        
        
        
        
        
        "section-after": eval("3em"),
        "photo-size": eval("100pt"),
        "photo-radius": eval("50%"),
        "photo-border": true,
        "photo-border-width": eval("4pt"),
        "section-before": eval("2em"),
        
        
        
        
        
      ),
          ),
      (
      id: "contact",
      title: "Contact",
            items: (
                              (type: "phone"),
                                        (type: "email"),
                                        (type: "city"),
                                        (type: "birthdate"),
                                        (type: "nationality"),
                                        (type: "permit"),
                                        (type: "linkedin"),
                                        (type: "github"),
                        ),
            
            style: (
        
        
        
        
        
        
        
        "item-after": eval("0em"),
        "section-after": eval("3em"),
        
        
        
        
        
        
        
        
        
        
      ),
          ),
      (
      id: "languages",
      title: "Languages",
            items: (
                              (name: "French", value: "Native", ),
                                        (name: "English", value: "C1 --- Fluent", ),
                                        (name: "Spanish", value: "B2 --- Intermediate", ),
                        ),
            
            style: (
        "text-size": eval("10pt"),
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
      ),
          ),
      (
      id: "skills",
      title: "IT Skills",
            items: (
                              (category: "Languages", items: "Python, R, SQL, JavaScript"),
                                        (category: "ML / Data", items: "scikit-learn, XGBoost, MLflow"),
                                        (category: "Tools", items: "Git, Docker, VS Code, Quarto"),
                                        (category: "Cloud", items: "Azure ML, GCP BigQuery"),
                        ),
            
            style: (
        "text-size": eval("9.5pt"),
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
      ),
          ),
      (
      id: "strengths",
      title: "Strengths",
            items: (
                              "Analytical mindset",
                                        "Team collaboration",
                                        "Fast learner",
                                        "Written communication",
                        ),
            
            style: (
        "text-size": eval("10pt"),
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
      ),
          ),
    ),
  sidebar-defaults: (
    "text-size": eval("8.5pt"),
    "title-size": eval("10pt"),
    "icon-size": eval("10pt"),
    "title-after": eval("0.8em"),
    "item-after": eval("0.7em"),
    "section-after": eval("2.5em"),
    
    
    
    
  ),
  section-order: (
          "photo", "contact", "networks", "skills", "languages", "strengths", "interests"
      ),
  layout-config: (
           "sidebar-width": eval("30%"), 
       "main-width": eval("2.5fr"), 
       "gutter": eval("1cm"), 
       "sidebar-bg": rgb("\#f1f5f9".replace("\#", "#")), 
       "main-bg": rgb("\#ffffff".replace("\#", "#")), 
              "margins": (
            "top": eval("0.5cm"), 
            "bottom": eval("0.5cm"), 
            "left": eval("0.5cm"), 
            "right": eval("0.5cm"), 
        ),
                    "timeline": (
           
           
            "dot-size": eval("3pt"), 
            "line-width": eval("1pt"), 
            "dot-color": rgb("\#2563eb".replace("\#", "#")), 
           
        ),
            ),
  theme: (
     "main-font": "Poppins", 
     "title-font": "Poppins", 
     "text-font": "Poppins", 
          "sidebar": (
          "title-color": rgb("\#2563eb".replace("\#", "#")), 
          "text-color": rgb("\#1e293b".replace("\#", "#")), 
          "accent-color": rgb("\#64748b".replace("\#", "#")), 
          "link-color": rgb("\#2563eb".replace("\#", "#")), 
          "icon-color": rgb("\#2563eb".replace("\#", "#")), 
          "photo-border-color": rgb("\#2563eb".replace("\#", "#")), 
         
         
      ),
      "main": (
          "title-color": rgb("\#2563eb".replace("\#", "#")), 
          "subtitle-color": rgb("\#1e293b".replace("\#", "#")), 
          "text-color": rgb("\#1e293b".replace("\#", "#")), 
         
      ),
      "headings": (
          "h1": "12pt", 
          "h2": "9pt", 
          "h3": "8pt", 
         
         
          "normal": "9pt", 
      ),
      "header": (
         
         
         
         
         
      ),
      ),
  date: "2026-05-01",
  date-prefix: "Last updated:",
  cv-header: (
    "name": "Marie Dupont",
    "title": "Data Scientist · ML Engineer",
    "objective": "Seeking a data science position where I can apply statistical modelling and machine-learning expertise to build impactful data products in a collaborative environment.",
    
    
    
    
    
    
    
  ),
  doc,
)

= Education
<education>
#timeline-section(levels: (1,2,3,4,5,6,))[
== 2021 - 2023 | MSc Data Science & Artificial Intelligence
<msc-data-science-artificial-intelligence>
#emph[École Polytechnique, Paris | Valedictorian --- mention Très Bien]

Coursework: statistical learning, deep learning, NLP, causal inference, distributed computing.

== 2018 - 2021 | BSc Mathematics & Computer Science
<bsc-mathematics-computer-science>
#emph[Université Paris-Saclay | Ranked 3rd / 120]

Strong foundation in probability, linear algebra, algorithms and software engineering.

]
= Professional Experience
<professional-experience>
#timeline-section(levels: (2,3,4,))[
== Jan.~2024 - Present | Data Scientist
<jan.-2024---present-data-scientist>
#emph[BNP Paribas, Paris]

Developed an end-to-end ML pipeline for credit-risk scoring (XGBoost + SHAP explainability), reducing false-positive rate by 18 %. Tech stack: Python, MLflow, Azure ML, SQL Server.

== Apr.~2023 - Dec.~2023 | ML Research Intern
<apr.-2023---dec.-2023-ml-research-intern>
#emph[INRIA -- TAU Team, Saclay]

Investigated fairness in ranking algorithms for job-search platforms (project #strong[FairRank]). Published results at ECML-PKDD 2023 workshop.

== Jun.~2022 - Aug.~2022 | Data Engineering Intern
<jun.-2022---aug.-2022-data-engineering-intern>
#emph[Criteo, Paris]

Built real-time feature pipelines with Apache Kafka and Spark Structured Streaming. Reduced daily batch latency by 35 %.

== 2021 | Volunteer Data Analyst
<volunteer-data-analyst>
#emph[Médecins Sans Frontières, remote]

Cleaned and visualised epidemiological datasets to support field reporting.

]
= Projects & Publications
<projects-publications>
#timeline-section(levels: (1,2,3,4,5,6,))[
== 2023 | FairRank --- Fairness-aware Learning-to-Rank
<fairrank-fairness-aware-learning-to-rank>
#emph[ECML-PKDD 2023 workshop paper]

Proposed a post-processing re-ranking algorithm that reduces demographic bias while preserving NDCG\@10 within 2 % of the unconstrained baseline.

== 2022 | OpenCV Sudoku Solver
<opencv-sudoku-solver>
#emph[Personal project --- #link("https://github.com/mdupont/sudoku-solver")[github.com/mdupont/sudoku-solver]]

Real-time Sudoku detection and solving pipeline using OpenCV and a CNN digit classifier (99.1 % accuracy on MNIST).

]



