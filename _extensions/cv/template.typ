// CV Template with sidebar layout
// Left column: contact info, skills
// Right column: experience, education

// --- Quarto Callout Support ---
#let bootstrap-icon(path, color: "black") = {
  let svg = "<?xml version='1.0' encoding='utf-8'?><svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='" + color + "' viewBox='0 0 16 16'><path d='" + path + "'/></svg>"
  box(width: 1.1em, height: 1.1em, baseline: 0.2em, image.decode(svg))
}

#let fa-info() = bootstrap-icon("M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2z", color: "#0d6efd")
#let fa-check() = [✓]
#let fa-warning() = [!]
#let fa-error() = [x]

#let callout(body: none, title: none, background_color: none, icon: none, icon_color: none) = {
  block(
    width: 100%,
    fill: rgb("#ffffff"),
    radius: 3pt,
    clip: true, // Ensure header bg follows radius
    stroke: (
        left: 2.5pt + icon_color, 
        top: 0.5pt + icon_color, 
        bottom: 0.5pt + icon_color, 
        right: 0.5pt + icon_color
    )
  )[
    #if title != none {
       block(
         width: 100%,
         fill: background_color, // Light color from Quarto
         inset: (x: 0.8em, y: 0.6em),
         below: 0pt, // sticky to body
         grid(
           columns: (auto, 1fr),
           gutter: 0.75em,
           align: (left + horizon, left + horizon),
           text(fill: icon_color)[#icon], 
           text(weight: "bold", fill: black)[#title]
         )
       )
    }
    #block(
       width: 100%,
       inset: 1em,
       above: 0pt,
    )[
       #body
    ]
  ]
}
// -----------------------------

// --- Quarto Columns Support ---
// Renders content as side-by-side columns using Typst grid
#let columns-layout(..children) = {
  let items = children.pos()
  let n = items.len()
  if n == 0 { return }
  grid(
    columns: (1fr,) * n,
    gutter: 1.5em,
    ..items
  )
}
// Global State for Theme
#let theme-state = state("cv-theme-state", (:))

#let horizontalrule = context {
  let theme = theme-state.get()
  let color = if "main" in theme and "title-color" in theme.main {
     theme.main.title-color
  } else {
     rgb("#2563eb") // Fallback
  }
  
  v(0.5em)
  line(length: 100%, stroke: 1pt + color)
  v(0.5em)
}

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
     
     // Helper function that positions dot aligned with text baseline
     // The dot is placed in an inline box that aligns with the text center
     let add-dot(it) = {
       // Create the heading with the dot positioned absolutely
       // Using 0.35em centers the dot vertically regardless of font size
       block([
         #place(dx: dot-dx, dy: 0.65em, circle(radius: dot-size, fill: dot-color))
         #it
       ])
     }
     
     pad(left: 1em, block(
       width: 100%,
       inset: (left: inset-left),
       stroke: (left: line-width + line-color),
       breakable: true
     )[
       // Apply timeline dot - h1 needs larger dy offset due to styling differences
       #show heading.where(level: 1): it => if 1 in levels { 
         block([#place(dx: dot-dx, dy: 0.6em, circle(radius: dot-size, fill: dot-color)) #it])
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
      title-color: rgb("#2563eb"),
      text-color: rgb("#1e293b"),
      accent-color: rgb("#64748b"),
      link-color: rgb("#2563eb"),  // Sidebar link color
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
  
  // Update global theme state so horizontalrule can access it
  // Placed after page setup to ensure no interference with page margins
  theme-state.update(current-theme)
  
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
      let icon-map = (
        phone: "icons/telephone.svg",
        email: "icons/envelope.svg",
        birthdate: "icons/calendar-event.svg",
        city: "icons/geo-alt.svg",
        nationality: "icons/flag.svg",
        permit: "icons/person-vcard.svg",
        website: "icons/link-45deg.svg",
        linkedin: "icons/linkedin.svg",
        github: "icons/github.svg",
      )
      
      let content-val = get-sidebar-data(item-type)
      let icon-path = icon-map.at(item-type, default: none)
      
      if content-val != none and content-val != "" and icon-path != none {
        // Read the SVG content
        let icon-data = read(icon-path)
        
        // Determine icon color: use style.icon-color if set (custom), otherwise theme title-color (default)
        let target-color = style.at("icon-color", default: current-theme.sidebar.title-color)
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
              text(font: style.text-font, size: style.text-size)[#link("tel:" + content-val)[#content-val]]
            } else if item-type == "email" {
              text(font: style.text-font, size: style.text-size)[#link("mailto:" + content-val)[#content-val]]
            } else if item-type in ("website", "linkedin", "github") {
              let display-val = get-sidebar-data(item-type + "-display")
              let default-label = if item-type == "linkedin" { "LinkedIn" } else if item-type == "github" { "GitHub" } else if item-type == "website" { content-val.replace("https://", "").replace("http://", "") } else { content-val }
              let label = if display-val != none { display-val } else { default-label }
              text(font: style.text-font, size: style.text-size)[#link(content-val)[#label]]
            } else {
              text(font: style.text-font, size: style.text-size)[#content-val]
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
        let stroke-val = if show-border { border-width + current-theme.sidebar.title-color } else { none }
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
              let item-color = style.at("item-color", default: rgb("#64748b"))
              let subitem-color = style.at("subitem-color", default: rgb("#94a3b8"))
              
              if "subitems" in item and item.subitems != none {
                // Name + subitems
                box[
                  #text(font: style.text-font)[• #item.name]
                  #for subitem in item.subitems {
                    linebreak()
                    h(0.8em)
                    text(font: style.text-font, fill: subitem-color)[◦ #subitem]
                  }
                ]
              } else if "value" in item and item.value != "" {
                // Name : value
                box[#text(font: style.text-font, weight: "semibold")[#item.name] : #text(font: style.text-font, fill: item-color)[#item.value]]
              } else {
                // Just name
                text(font: style.text-font)[• #item.name]
              }
            } else { none }
          } else if item != "" {
            // Simple list format
            text(font: style.text-font)[• #item]
          } else { none }
        }).filter(x => x != none)
        
        // Render all with stack to control spacing precisely
        if items-content.len() > 0 {
          stack(dir: ttb, spacing: item-gap, ..items-content)
        }
      } else if "content" in section and section.content != "" {
        // Text block format
        text[#section.content]
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
    let timeline-dy = if layout-config != none and "timeline" in layout-config and "dy" in layout-config.timeline { layout-config.timeline.dy } else { 0.25em }
    
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

// Apply template
#show: doc => cv(
  title: "$title$",
  subtitle: "$subtitle$",
  // Sidebar data block
  sidebar: (
$if(sidebar)$
    $if(sidebar.photo)$"photo": "$sidebar.photo$",$endif$
    $if(sidebar.phone)$"phone": "$sidebar.phone$",$endif$
    $if(sidebar.email)$"email": "$sidebar.email$".replace("\@", "@"),$endif$
    $if(sidebar.birthdate)$"birthdate": "$sidebar.birthdate$",$endif$
    $if(sidebar.city)$"city": "$sidebar.city$",$endif$
    $if(sidebar.nationality)$"nationality": "$sidebar.nationality$",$endif$
    $if(sidebar.website)$"website": "$sidebar.website$".replace("\/", "/"),$endif$
    $if(sidebar.website-display)$"website-display": "$sidebar.website-display$".replace("\@", "@"),$endif$
    $if(sidebar.permit)$"permit": "$sidebar.permit$",$endif$
    $if(sidebar.linkedin)$"linkedin": "$sidebar.linkedin$".replace("\/", "/"),$endif$
    $if(sidebar.linkedin-display)$"linkedin-display": "$sidebar.linkedin-display$".replace("\@", "@"),$endif$
    $if(sidebar.github)$"github": "$sidebar.github$".replace("\/", "/"),$endif$
    $if(sidebar.github-display)$"github-display": "$sidebar.github-display$".replace("\@", "@"),$endif$
$else$
    // Legacy fallback
    $if(photo)$"photo": "$photo$",$endif$
    $if(phone)$"phone": "$phone$",$endif$
    $if(email)$"email": "$email$",$endif$
    $if(birthdate)$"birthdate": "$birthdate$",$endif$
    $if(city)$"city": "$city$",$endif$
    $if(nationality)$"nationality": "$nationality$",$endif$
    $if(website-url)$"website": "$website-url$",$endif$
    $if(permit)$"permit": "$permit$",$endif$
    $if(linkedin)$"linkedin": "$linkedin$",$endif$
    $if(github)$"github": "$github$",$endif$
$endif$
  ),
  // Legacy individual params (backwards compatibility)
  photo: $if(photo)$"$photo$"$else$none$endif$,
  phone: "$phone$",
  email: "$email$",
  birthdate: "$birthdate$",
  city: "$city$",
  nationality: "$nationality$",
  website: $if(website-url)$"$website-url$"$else$none$endif$,
  permit: "$permit$",
  linkedin: $if(linkedin)$"$linkedin$"$else$none$endif$,
  github: $if(github)$"$github$"$else$none$endif$,
  // Manual customizations hooks
  // Manual customizations hooks
  // Manual customizations hooks
  sidebar-styles: (
    "global": (
      "__is_style": true,
      $if(sidebar-styles.global.text-size)$ "text-size": eval("$sidebar-styles.global.text-size$"), $endif$
      $if(sidebar-styles.global.title-size)$ "title-size": eval("$sidebar-styles.global.title-size$"), $endif$
      $if(sidebar-styles.global.icon-size)$ "icon-size": eval("$sidebar-styles.global.icon-size$"), $endif$
      $if(sidebar-styles.global.section-spacing)$ "section-spacing": eval("$sidebar-styles.global.section-spacing$"), $endif$
      $if(sidebar-styles.global.item-spacing)$ "item-spacing": eval("$sidebar-styles.global.item-spacing$"), $endif$
      $if(sidebar-styles.global.photo-size)$ "photo-size": eval("$sidebar-styles.global.photo-size$"), $endif$
      $if(sidebar-styles.global.photo-radius)$ "photo-radius": eval("$sidebar-styles.global.photo-radius$"), $endif$
    ),
    "contact": (
      "__is_style": true,
      $if(sidebar-styles.contact.text-size)$ "text-size": eval("$sidebar-styles.contact.text-size$"), $endif$
      $if(sidebar-styles.contact.title-size)$ "title-size": eval("$sidebar-styles.contact.title-size$"), $endif$
      $if(sidebar-styles.contact.icon-size)$ "icon-size": eval("$sidebar-styles.contact.icon-size$"), $endif$
      $if(sidebar-styles.contact.section-spacing)$ "section-spacing": eval("$sidebar-styles.contact.section-spacing$"), $endif$
      $if(sidebar-styles.contact.item-spacing)$ "item-spacing": eval("$sidebar-styles.contact.item-spacing$"), $endif$
    ),
    "networks": (
      "__is_style": true,
      $if(sidebar-styles.networks.text-size)$ "text-size": eval("$sidebar-styles.networks.text-size$"), $endif$
      $if(sidebar-styles.networks.title-size)$ "title-size": eval("$sidebar-styles.networks.title-size$"), $endif$
      $if(sidebar-styles.networks.icon-size)$ "icon-size": eval("$sidebar-styles.networks.icon-size$"), $endif$
      $if(sidebar-styles.networks.section-spacing)$ "section-spacing": eval("$sidebar-styles.networks.section-spacing$"), $endif$
      $if(sidebar-styles.networks.item-spacing)$ "item-spacing": eval("$sidebar-styles.networks.item-spacing$"), $endif$
    ),
    "skills": (
      "__is_style": true,
      $if(sidebar-styles.skills.text-size)$ "text-size": eval("$sidebar-styles.skills.text-size$"), $endif$
      $if(sidebar-styles.skills.title-size)$ "title-size": eval("$sidebar-styles.skills.title-size$"), $endif$
      $if(sidebar-styles.skills.icon-size)$ "icon-size": eval("$sidebar-styles.skills.icon-size$"), $endif$
      $if(sidebar-styles.skills.section-spacing)$ "section-spacing": eval("$sidebar-styles.skills.section-spacing$"), $endif$
      $if(sidebar-styles.skills.item-spacing)$ "item-spacing": eval("$sidebar-styles.skills.item-spacing$"), $endif$
    ),
    "languages": (
      "__is_style": true,
      $if(sidebar-styles.languages.text-size)$ "text-size": eval("$sidebar-styles.languages.text-size$"), $endif$
      $if(sidebar-styles.languages.title-size)$ "title-size": eval("$sidebar-styles.languages.title-size$"), $endif$
      $if(sidebar-styles.languages.icon-size)$ "icon-size": eval("$sidebar-styles.languages.icon-size$"), $endif$
      $if(sidebar-styles.languages.section-spacing)$ "section-spacing": eval("$sidebar-styles.languages.section-spacing$"), $endif$
      $if(sidebar-styles.languages.item-spacing)$ "item-spacing": eval("$sidebar-styles.languages.item-spacing$"), $endif$
    ),
    "strengths": (
      "__is_style": true,
      $if(sidebar-styles.strengths.text-size)$ "text-size": eval("$sidebar-styles.strengths.text-size$"), $endif$
      $if(sidebar-styles.strengths.title-size)$ "title-size": eval("$sidebar-styles.strengths.title-size$"), $endif$
      $if(sidebar-styles.strengths.icon-size)$ "icon-size": eval("$sidebar-styles.strengths.icon-size$"), $endif$
      $if(sidebar-styles.strengths.section-spacing)$ "section-spacing": eval("$sidebar-styles.strengths.section-spacing$"), $endif$
      $if(sidebar-styles.strengths.item-spacing)$ "item-spacing": eval("$sidebar-styles.strengths.item-spacing$"), $endif$
    ),
    "interests": (
      "__is_style": true,
      $if(sidebar-styles.interests.text-size)$ "text-size": eval("$sidebar-styles.interests.text-size$"), $endif$
      $if(sidebar-styles.interests.title-size)$ "title-size": eval("$sidebar-styles.interests.title-size$"), $endif$
      $if(sidebar-styles.interests.icon-size)$ "icon-size": eval("$sidebar-styles.interests.icon-size$"), $endif$
      $if(sidebar-styles.interests.section-spacing)$ "section-spacing": eval("$sidebar-styles.interests.section-spacing$"), $endif$
      $if(sidebar-styles.interests.item-spacing)$ "item-spacing": eval("$sidebar-styles.interests.item-spacing$"), $endif$
    ),
    "photo": (
      "__is_style": true,
      $if(sidebar-styles.photo.text-size)$ "text-size": eval("$sidebar-styles.photo.text-size$"), $endif$
      $if(sidebar-styles.photo.title-size)$ "title-size": eval("$sidebar-styles.photo.title-size$"), $endif$
      $if(sidebar-styles.photo.icon-size)$ "icon-size": eval("$sidebar-styles.photo.icon-size$"), $endif$
      $if(sidebar-styles.photo.section-spacing)$ "section-spacing": eval("$sidebar-styles.photo.section-spacing$"), $endif$
      $if(sidebar-styles.photo.item-spacing)$ "item-spacing": eval("$sidebar-styles.photo.item-spacing$"), $endif$
      $if(sidebar-styles.photo.photo-size)$ "photo-size": eval("$sidebar-styles.photo.photo-size$"), $endif$
      $if(sidebar-styles.photo.photo-radius)$ "photo-radius": eval("$sidebar-styles.photo.photo-radius$"), $endif$
    ),
  ),
  sidebar-sections: (
$if(sidebar-sections)$
  $for(sidebar-sections)$
    (
      id: "$sidebar-sections.id$",
      $if(sidebar-sections.title)$title: "$sidebar-sections.title$",$endif$
      $if(sidebar-sections.items)$
      items: (
        $for(sidebar-sections.items)$
          $if(sidebar-sections.items.type)$
            (type: "$sidebar-sections.items.type$"),
          $elseif(sidebar-sections.items.category)$
            (category: "$sidebar-sections.items.category$", $if(sidebar-sections.items.items)$items: "$sidebar-sections.items.items$"$endif$),
          $elseif(sidebar-sections.items.name)$
            (name: "$sidebar-sections.items.name$", $if(sidebar-sections.items.value)$value: "$sidebar-sections.items.value$",$endif$ $if(sidebar-sections.items.subitems)$subitems: ($for(sidebar-sections.items.subitems)$"$sidebar-sections.items.subitems$",$endfor$),$endif$),
          $else$
            "$sidebar-sections.items$",
          $endif$
        $endfor$
      ),
      $endif$
      $if(sidebar-sections.content)$content: "$sidebar-sections.content$",$endif$
      $if(sidebar-sections.style)$
      style: (
        $if(sidebar-sections.style.text-size)$"text-size": eval("$sidebar-sections.style.text-size$"),$endif$
        $if(sidebar-sections.style.title-size)$"title-size": eval("$sidebar-sections.style.title-size$"),$endif$
        $if(sidebar-sections.style.title-font)$"title-font": "$sidebar-sections.style.title-font$",$endif$
        $if(sidebar-sections.style.text-font)$"text-font": "$sidebar-sections.style.text-font$",$endif$
        $if(sidebar-sections.style.icon-size)$"icon-size": eval("$sidebar-sections.style.icon-size$"),$endif$
        $if(sidebar-sections.style.icon-color)$"icon-color": rgb("$sidebar-sections.style.icon-color$".replace("\#", "#")),$endif$
        $if(sidebar-sections.style.title-after)$"title-after": eval("$sidebar-sections.style.title-after$"),$endif$
        $if(sidebar-sections.style.item-after)$"item-after": eval("$sidebar-sections.style.item-after$"),$endif$
        $if(sidebar-sections.style.section-after)$"section-after": eval("$sidebar-sections.style.section-after$"),$endif$
        $if(sidebar-sections.style.photo-size)$"photo-size": eval("$sidebar-sections.style.photo-size$"),$endif$
        $if(sidebar-sections.style.photo-radius)$"photo-radius": eval("$sidebar-sections.style.photo-radius$"),$endif$
        $if(sidebar-sections.style.photo-border)$"photo-border": $sidebar-sections.style.photo-border$,$endif$
        $if(sidebar-sections.style.photo-border-width)$"photo-border-width": eval("$sidebar-sections.style.photo-border-width$"),$endif$
        $if(sidebar-sections.style.section-before)$"section-before": eval("$sidebar-sections.style.section-before$"),$endif$
        $if(sidebar-sections.style.category-size)$"category-size": eval("$sidebar-sections.style.category-size$"),$endif$
        $if(sidebar-sections.style.category-color)$"category-color": rgb("$sidebar-sections.style.category-color$".replace("\#", "#")),$endif$
        $if(sidebar-sections.style.item-color)$"item-color": rgb("$sidebar-sections.style.item-color$".replace("\#", "#")),$endif$
        $if(sidebar-sections.style.subitem-color)$"subitem-color": rgb("$sidebar-sections.style.subitem-color$".replace("\#", "#")),$endif$
      ),
      $endif$
    ),
  $endfor$
$endif$
  ),
  sidebar-defaults: (
$if(sidebar-defaults)$
    $if(sidebar-defaults.text-size)$"text-size": eval("$sidebar-defaults.text-size$"),$endif$
    $if(sidebar-defaults.title-size)$"title-size": eval("$sidebar-defaults.title-size$"),$endif$
    $if(sidebar-defaults.icon-size)$"icon-size": eval("$sidebar-defaults.icon-size$"),$endif$
    $if(sidebar-defaults.title-after)$"title-after": eval("$sidebar-defaults.title-after$"),$endif$
    $if(sidebar-defaults.item-after)$"item-after": eval("$sidebar-defaults.item-after$"),$endif$
    $if(sidebar-defaults.section-after)$"section-after": eval("$sidebar-defaults.section-after$"),$endif$
    $if(sidebar-defaults.category-size)$"category-size": eval("$sidebar-defaults.category-size$"),$endif$
    $if(sidebar-defaults.category-color)$"category-color": rgb("$sidebar-defaults.category-color$".replace("\#", "#")),$endif$
    $if(sidebar-defaults.item-color)$"item-color": rgb("$sidebar-defaults.item-color$".replace("\#", "#")),$endif$
    $if(sidebar-defaults.subitem-color)$"subitem-color": rgb("$sidebar-defaults.subitem-color$".replace("\#", "#")),$endif$
$endif$
  ),
  section-order: (
    $if(section-order)$
      $for(section-order)$
        "$it$",
      $endfor$
    $else$
      "photo", "contact", "networks", "skills", "languages", "strengths", "interests"
    $endif$
  ),
  layout-config: (
    $if(cv-layout)$
      $if(cv-layout.sidebar-width)$ "sidebar-width": eval("$cv-layout.sidebar-width$"), $endif$
      $if(cv-layout.main-width)$ "main-width": eval("$cv-layout.main-width$"), $endif$
      $if(cv-layout.gutter)$ "gutter": eval("$cv-layout.gutter$"), $endif$
      $if(cv-layout.sidebar-bg)$ "sidebar-bg": rgb("$cv-layout.sidebar-bg$".replace("\#", "#")), $endif$
      $if(cv-layout.main-bg)$ "main-bg": rgb("$cv-layout.main-bg$".replace("\#", "#")), $endif$
      $if(cv-layout.margins)$ 
        "margins": (
           $if(cv-layout.margins.top)$ "top": eval("$cv-layout.margins.top$"), $endif$
           $if(cv-layout.margins.bottom)$ "bottom": eval("$cv-layout.margins.bottom$"), $endif$
           $if(cv-layout.margins.left)$ "left": eval("$cv-layout.margins.left$"), $endif$
           $if(cv-layout.margins.right)$ "right": eval("$cv-layout.margins.right$"), $endif$
        ),
      $endif$
      $if(cv-layout.timeline)$
        "timeline": (
           $if(cv-layout.timeline.dx)$ "dx": eval("$cv-layout.timeline.dx$"), $endif$
           $if(cv-layout.timeline.dy)$ "dy": eval("$cv-layout.timeline.dy$"), $endif$
           $if(cv-layout.timeline.dot-size)$ "dot-size": eval("$cv-layout.timeline.dot-size$"), $endif$
           $if(cv-layout.timeline.line-width)$ "line-width": eval("$cv-layout.timeline.line-width$"), $endif$
           $if(cv-layout.timeline.dot-color)$ "dot-color": rgb("$cv-layout.timeline.dot-color$".replace("\#", "#")), $endif$
           $if(cv-layout.timeline.line-color)$ "line-color": rgb("$cv-layout.timeline.line-color$".replace("\#", "#")), $endif$
        ),
      $endif$
    $endif$
  ),
  theme: (
    $if(cv-theme)$
      $if(cv-theme.main-font)$ "main-font": "$cv-theme.main-font$", $endif$
      $if(cv-theme.title-font)$ "title-font": "$cv-theme.title-font$", $endif$
      $if(cv-theme.text-font)$ "text-font": "$cv-theme.text-font$", $endif$
      "sidebar": (
         $if(cv-theme.sidebar.title-color)$ "title-color": rgb("$cv-theme.sidebar.title-color$".replace("\#", "#")), $endif$
         $if(cv-theme.sidebar.text-color)$ "text-color": rgb("$cv-theme.sidebar.text-color$".replace("\#", "#")), $endif$
         $if(cv-theme.sidebar.accent-color)$ "accent-color": rgb("$cv-theme.sidebar.accent-color$".replace("\#", "#")), $endif$
         $if(cv-theme.sidebar.title-size)$ "title-size": "$cv-theme.sidebar.title-size$", $endif$
         $if(cv-theme.sidebar.text-size)$ "text-size": "$cv-theme.sidebar.text-size$", $endif$
      ),
      "main": (
         $if(cv-theme.main.title-color)$ "title-color": rgb("$cv-theme.main.title-color$".replace("\#", "#")), $endif$
         $if(cv-theme.main.subtitle-color)$ "subtitle-color": rgb("$cv-theme.main.subtitle-color$".replace("\#", "#")), $endif$
         $if(cv-theme.main.text-color)$ "text-color": rgb("$cv-theme.main.text-color$".replace("\#", "#")), $endif$
         $if(cv-theme.main.link-color)$ "link-color": rgb("$cv-theme.main.link-color$".replace("\#", "#")), $endif$
      ),
      "headings": (
         $if(cv-theme.headings.h1)$ "h1": "$cv-theme.headings.h1$", $endif$
         $if(cv-theme.headings.h2)$ "h2": "$cv-theme.headings.h2$", $endif$
         $if(cv-theme.headings.h3)$ "h3": "$cv-theme.headings.h3$", $endif$
         $if(cv-theme.headings.h4)$ "h4": "$cv-theme.headings.h4$", $endif$
         $if(cv-theme.headings.h5-h6)$ "h5-h6": "$cv-theme.headings.h5-h6$", $endif$
         $if(cv-theme.headings.normal)$ "normal": "$cv-theme.headings.normal$", $endif$
      ),
    $endif$
  ),
  date: "$date$",
  date-prefix: "$if(date-prefix)$$date-prefix$$else$Last updated: $endif$",
  doc,
)

$body$
