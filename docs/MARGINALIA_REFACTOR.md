# Marginalia-Based Sidebar Refactor — Complete Architecture

## Overview

This document outlines a proposed refactor of the quarto-cv template to leverage Quarto 1.9's **marginalia** package for Typst, replacing the current fixed 2-column layout with a flexible, margin-based approach.

### Key Improvements

- ✅ **Flexible margin system** — left, right, top, bottom marges independently configurable
- ✅ **Quarto-native** — uses standard `column: margin` syntax, not custom YAML DSL
- ✅ **Auto-positioning** — marginalia handles vertical stacking and overlap prevention
- ✅ **More content space** — main content not constrained to 70% width
- ✅ **Better maintainability** — sidebar defined in markdown, not massive YAML blocks
- ✅ **Native figure support** — `column: margin` for R/Python plots works natively

---

## Architecture

### Complete Layout Structure

```
┌─────────────────────────────────────────────────┐
│     TOP MARGIN (Header Section)                 │
│  Name, Title, Objective                         │
├─────────────┬─────────────────────┬─────────────┤
│  LEFT       │   MAIN CONTENT      │   RIGHT     │
│  MARGIN     │                     │   MARGIN    │
│             │  - Education        │             │
│  - Contact  │  - Experience       │  - Skills   │
│  - Photo    │  - Projects         │  - Languages│
│  - Networks │  - Visualizations   │  - Interests│
│             │                     │             │
├─────────────┴─────────────────────┴─────────────┤
│     BOTTOM MARGIN (Footer Section)              │
│  Certifications, Acknowledgments, Links         │
└─────────────────────────────────────────────────┘
```

### What Goes Where

| Margin | Typical Content | Width | Notes |
|--------|---|---|---|
| **TOP** | Name, Title, Objective | Full width | Spans all columns |
| **LEFT** | Photo, Contact, Networks | ~18-20mm | Narrow, auto-stacks |
| **RIGHT** | Skills, Languages, Interests | ~18-20mm | Narrow, auto-stacks |
| **BOTTOM** | Certifications, Footer | Full width | Spans all columns |
| **CENTER** | Main CV content | Flexible | Education, Experience, Projects |

---

## YAML Configuration

### Minimal Frontmatter (the new approach)

```yaml
---
title: "CV - First Last"
author: "First Last"
date: last-modified
date-prefix: "Last updated: "
format: quarto-cv-typst: default

# Global theme (just colors, fonts, sizes)
cv-theme:
  main-font: "Poppins"
  title-font: "Poppins"
  text-font: "Poppins"
  
  sidebar:
    title-color: "#2563eb"
    text-color: "#1e293b"
    accent-color: "#64748b"
    link-color: "#2563eb"
    icon-color: "#2563eb"
  
  main:
    title-color: "#2563eb"
    subtitle-color: "#1e293b"
    text-color: "#1e293b"
    link-color: "#2563eb"
  
  headings:
    h1: 14pt
    h2: 11pt
    h3: 10pt
    normal: 10pt

# Layout with margins
cv-layout:
  # Margin widths (configurable)
  margin-top-height: "6cm"        # Header area
  margin-bottom-height: "3cm"     # Footer area
  margin-left-width: "18mm"       # Left sidebar
  margin-right-width: "20mm"      # Right sidebar
  
  # Margin styling
  margin-left-bg: "#f1f5f9"
  margin-right-bg: "#ffffff"
  margin-left-color: "#1e293b"
  margin-right-color: "#1e293b"
  
  # Main content area
  main-width: auto                # Flexible (not fixed %)
  main-bg: "#ffffff"
  main-text-color: "#1e293b"
  
  # Page margins
  margins:
    top: 0.5cm
    bottom: 0.5cm
    left: 0.5cm
    right: 0.5cm
  
  # Timeline styling
  timeline:
    dot-size: "2pt"
    line-width: "1pt"
    dot-color: "#2563eb"
    line-color: "#2563eb"

# Header content (in YAML, minimal)
cv-header:
  name: "First Last"
  title: "Job Title"
  objective: |
    Your professional summary in 2-3 sentences...
---
```

### What Changed from Current Template

**Before (2-column):**
```yaml
sidebar-sections:
  - id: contact
    title: "Contact"
    items:
      - type: phone
      - type: email
      - type: city
    style:
      text-size: 9pt
      icon-color: "#2563eb"
```

**After (marginalia):**
```yaml
# Just colors/fonts in cv-theme, no sidebar-sections!
# Everything else goes in markdown
```

---

## Markdown Structure

### Complete Document Example

```markdown
---
# (YAML frontmatter from above)
---

# Header Section (Top Margin)

::: {.cv-header}
#| column: margin-top
### First Last
ML Research Engineer · Data Scientist

Passionate about building fair and interpretable 
machine learning systems with expertise in deep 
learning and computer vision.
:::

---

# Left Margin Section

::: {.sidebar-left}
#| column: margin

### Contact
- **Phone:** +33 7 XX XX XX XX
- **Email:** user@example.com
- **City:** Paris, France
- **LinkedIn:** [in/firstname-lastname](https://linkedin.com/in/...)
- **GitHub:** [@username](https://github.com/...)

### Languages
- **French** — Native
- **English** — C1 Fluent
- **German** — B1 Intermediate

### Interests
- AI & Ethics
- Computer Vision
- Time Series Analysis

:::

---

# Main Content

## Education

::: {.timeline}

### MSc Bioinformatics | 2022–2024
*University of Paris*

Focus on machine learning and genomic data analysis.

:::

## Experience

::: {.timeline}

### ML Engineer | 2024–Present
*TechCorp, Paris*

Leading development of fairness-aware ML models.

:::

---

# Right Margin Section

::: {.sidebar-right}
#| column: margin

### Technical Skills
- **Languages:** Python, R, SQL, Bash
- **ML Frameworks:** TensorFlow, PyTorch, scikit-learn
- **Tools:** Git, Docker, Jupyter, Quarto
- **Cloud:** AWS, GCP, Azure

### Certifications
- AWS Certified ML — Specialty
- Google Cloud Professional Data Engineer
- Deep Learning Specialization (Coursera)

:::

---

# Footer Section (Bottom Margin)

::: {.cv-footer}
#| column: margin-bottom

### Publications
- "Fair Vision: Bias Detection..." — IEEE CVPR 2024
- [Full list on Google Scholar](...)

### Awards
- Prix de l'Excellence en IA (2024)
- Google Cloud Challenge Winner (2023)

:::
```

---

## How `column: margin` Works

### Basic Syntax

```markdown
::: {.sidebar-section}
#| column: margin-left

### Section Title
Content goes here...
:::
```

### Margin Options

| Option | Behavior |
|--------|----------|
| `column: margin-left` | Places in left margin, auto-stacks vertically |
| `column: margin-right` | Places in right margin, auto-stacks vertically |
| `column: margin-top` | Places in top margin, full width |
| `column: margin-bottom` | Places in bottom margin, full width |
| `column: margin` | Auto-chooses side (default right) |

### Quarto Native Features

```markdown
# Figures in margin
::: {.sidebar-right}
#| column: margin

```{r}
#| fig-cap: "Model Performance"
ggplot(data) + geom_point()
```
:::

# Tables in margin
::: {.sidebar-right}
#| column: margin

| Skill | Level |
|-------|-------|
| Python | Expert |
| R | Advanced |
```
:::
```

---

## Section Types & Styling

### Photo Section (Left Margin)

```markdown
::: {.sidebar-left}
#| column: margin

![Profile Photo](assets/img/photo.png){width=80pt}

:::
```

**Styling (in cv-theme):**
```yaml
cv-theme:
  sidebar:
    photo-size: 80pt
    photo-radius: 50%        # circular
    photo-border: true
    photo-border-width: 3pt
    photo-border-color: "#2563eb"
```

### Contact Section (Left Margin)

```markdown
::: {.sidebar-left}
#| column: margin

### Contact
- **Email:** [user@example.com](mailto:...)
- **Phone:** +33 7 XX XX XX XX
- **City:** Paris, France
- **Website:** [example.com](https://example.com)
:::
```

### Skills with Categories (Right Margin)

```markdown
::: {.sidebar-right}
#| column: margin

### Technical Skills

**Languages:** Python, R, SQL, Bash

**ML Frameworks:** TensorFlow, PyTorch, scikit-learn

**Tools & DevOps:** Git, Docker, Kubernetes

:::
```

### Nested Lists (Left Margin)

```markdown
::: {.sidebar-left}
#| column: margin

### Interests
- AI & Ethics
  - Fairness in ML
  - Bias mitigation
- Computer Vision
  - Object detection
  - Image classification
- Time Series
  - Forecasting
  - Anomaly detection

:::
```

---

## Personalization & Styling

### Color Hierarchy System

Colors can be controlled at **5 levels** with cascading precedence:

1. **Global (cv-theme)** — Base colors for all text, titles, accents
2. **Margin-level (cv-layout)** — Different colors per margin (left vs right)
3. **Section-level** — Override color for entire sidebar section
4. **Item-level** — Color individual lines/items
5. **Character-level** — Color specific words (use sparingly)

**Precedence:** Character > Item > Section > Margin > Global

### Example: Hierarchical Color Strategy

#### Strategy 1: Minimal (Professional)

**Global base:**
```yaml
cv-theme:
  sidebar:
    text-color: "#1e293b"        # Neutral dark gray
    title-color: "#2563eb"       # Single accent: blue
    accent-color: "#64748b"      # Secondary: slate
```

**Margin colors:**
```yaml
cv-layout:
  margin-left-color: "#1e293b"   # Same as global
  margin-right-color: "#1e293b"  # Same as global
```

**Result:** Consistent, professional, one color accent

---

#### Strategy 2: Moderate (Balanced)

**Global base:**
```yaml
cv-theme:
  sidebar:
    text-color: "#1e293b"
    title-color: "#2563eb"       # Blue
    accent-color: "#059669"      # Green secondary
```

**Margin colors:**
```yaml
cv-layout:
  margin-left-color: "#1e293b"   # Left: neutral
  margin-right-color: "#059669"  # Right: green (different!)
  margin-left-bg: "#f1f5f9"      # Light bg
  margin-right-bg: "#f0fdf4"     # Light green bg
```

**Per-section items (markdown):**
```markdown
::: {.sidebar-left}
#| column: margin

### Contact
- [📧 Email]{style="color: #2563eb;"}: user@example.com
- [📱 Phone]{style="color: #2563eb;"}: +33 7 XX XX XX XX

:::

::: {.sidebar-right}
#| column: margin

### Skills
- [Languages:]{style="color: #059669; font-weight: bold;"} Python, R, SQL
- [ML Frameworks:]{style="color: #059669; font-weight: bold;"} TensorFlow, PyTorch

:::
```

**Result:** Visual distinction between left/right, 2-3 colors total, balanced

---

#### Strategy 3: Bold (Creative)

**Global base:**
```yaml
cv-theme:
  sidebar:
    text-color: "#0f172a"        # Dark
    title-color: "#dc2626"       # Red titles
    accent-color: "#7c3aed"      # Purple
```

**Margin colors (distinctive):**
```yaml
cv-layout:
  margin-left-color: "#0f172a"
  margin-left-bg: "#fef3f2"      # Light rose
  margin-right-color: "#7c3aed"  # Purple
  margin-right-bg: "#f5f3ff"     # Light purple
```

**Multi-color items (markdown):**
```markdown
::: {.sidebar-left}
#| column: margin

### Contact
- [🌐 Website]{style="color: #dc2626;"}: example.com
- [📧 Email]{style="color: #f59e0b;"}: user@example.com
- [📱 Phone]{style="color: #06b6d4;"}: +33 7 XX XX XX XX
- [📍 City]{style="color: #8b5cf6;"}: Paris

### Languages
- [🇫🇷 French]{style="color: #2563eb;"} — Native
- [🇬🇧 English]{style="color: #059669;"} — Fluent
- [🇩🇪 German]{style="color: #7c3aed;"} — Intermediate

:::
```

**Result:** Eye-catching, colorful, each element distinct

---

### Per-Section Style Overrides

```markdown
::: {.sidebar-left style="color: #AF1E42; font-weight: bold;"}
#| column: margin

### Contact (Custom Red)
Custom styling in this section only
:::
```

### Per-Margin Background Colors

In `cv-layout:`:
```yaml
cv-layout:
  margin-left-bg: "#f1f5f9"      # Light gray for left
  margin-right-bg: "#fef3f2"     # Light rose for right
  margin-left-color: "#1e293b"   # Dark text on left
  margin-right-color: "#7c3aed"  # Purple text on right
```

### Font Customization

```markdown
::: {.sidebar-left style="font-family: 'Courier New';"}
#| column: margin

### Programming Skills
Monospace font for code feel
:::
```

---

## Margin Layout Intersections

When using multiple margins simultaneously (top + left, top + right, etc.), it's important to understand how marginalia positions them.

### Intersection Case 1: TOP + LEFT Margins

**Visual Layout (Recommended: Sequential)**

```
┌─────────────────────────────────────────┐
│     TOP MARGIN (Full Width)             │
│  Name, Title, Objective                 │
│  Height: 6cm (configurable)             │
├──────────┬──────────────────────────────┤
│ LEFT     │  MAIN CONTENT                │
│ MARGIN   │  (Flexible width)            │
│ 18mm     │                              │
│          │  - Education                 │
│ Contact  │  - Experience                │
│ Languages│  - Projects                  │
│ Interests│                              │
│          │                              │
└──────────┴──────────────────────────────┘
```

**How it works:**
1. TOP margin occupies full width at top, with defined height
2. LEFT margin starts **below** TOP margin (sequential)
3. MAIN content starts to the right of LEFT margin
4. No overlap, natural reading flow

**Configuration:**

```yaml
cv-layout:
  # Top: full width, defined height
  margin-top-height: "6cm"
  margin-top-width: "100%"
  margin-top-bg: "#f1f5f9"
  
  # Left: starts after top, narrow column
  margin-left-width: "18mm"
  margin-left-bg: "#ffffff"
  
  # Main content: flexible, starts right of left margin
  main-width: auto
  main-bg: "#ffffff"
```

**Markdown structure:**

```markdown
---
# YAML frontmatter (see above)
---

::: {.cv-header}
#| column: margin-top
### First Last
ML Research Engineer

Objective: ...
:::

::: {.sidebar-left}
#| column: margin-left

### Contact
- Email: user@example.com
- Phone: +33 7 XX XX XX XX

### Languages
- French: Native
- English: Fluent

:::

# Main Content

## Education
...

## Experience
...

:::
```

---

### Intersection Case 2: TOP + LEFT + RIGHT Margins

```
┌─────────────────────────────────────────┐
│     TOP MARGIN (Full Width)             │
│  Name, Title, Objective                 │
├──────────┬──────────────────┬───────────┤
│ LEFT     │  MAIN CONTENT    │ RIGHT     │
│ MARGIN   │                  │ MARGIN    │
│          │  - Education     │           │
│ Contact  │  - Experience    │  Skills   │
│ Languages│  - Projects      │  Interests│
│          │                  │           │
├──────────┴──────────────────┴───────────┤
│     BOTTOM MARGIN (Full Width)          │
│  Certifications, Awards, Footer         │
└─────────────────────────────────────────┘
```

**How it works:**
1. TOP margin (full width) at top
2. LEFT, MAIN, RIGHT all sit **below** TOP margin
3. LEFT and RIGHT margins are parallel columns
4. BOTTOM margin (full width) at bottom, **after** all side margins
5. Marginalia auto-adjusts vertical spacing to prevent overlap

**Configuration:**

```yaml
cv-layout:
  # Top section
  margin-top-height: "6cm"
  margin-top-bg: "#f1f5f9"
  
  # Left + Right sections (parallel)
  margin-left-width: "18mm"
  margin-left-bg: "#ffffff"
  margin-right-width: "20mm"
  margin-right-bg: "#f0fdf4"
  
  # Bottom section
  margin-bottom-height: "3cm"
  margin-bottom-bg: "#f8fafc"
  
  # Main content (flexible)
  main-width: auto
  main-bg: "#ffffff"
```

**Markdown structure:**

```markdown
---
# YAML
---

::: {.cv-header}
#| column: margin-top
### First Last
### Title
Objective...
:::

::: {.sidebar-left}
#| column: margin-left
### Contact
...
### Languages
...
:::

# Education
(main content)

## Experience

::: {.sidebar-right}
#| column: margin-right
### Skills
...
### Interests
...
:::

::: {.cv-footer}
#| column: margin-bottom
### Certifications
...
### Awards
...
:::
```

---

### Intersection Case 3: All Margins (4-way)

This is the most complex layout with all four margins + main content.

```
┌─────────────────────────────────────────┐
│     TOP MARGIN (Full Width)             │
│  Name + Title + Objective               │
├──────────┬──────────────────┬───────────┤
│ LEFT     │  MAIN CONTENT    │ RIGHT     │
│ MARGIN   │                  │ MARGIN    │
│ 18mm     │  (Flexible)      │ 20mm      │
│          │                  │           │
│ Contact  │  - Education     │ Skills    │
│ Networks │  - Experience    │ Languages │
│ Languages│  - Projects      │ Interests │
│ Interests│  - Visualizations│           │
│          │                  │           │
├──────────┴──────────────────┴───────────┤
│     BOTTOM MARGIN (Full Width)          │
│  Certifications, Awards, Publications  │
└─────────────────────────────────────────┘
```

**How marginalia handles this:**
1. **Horizontal stacking:** TOP margin spans full width
2. **Vertical arrangement:** LEFT and RIGHT at same height level
3. **Main content:** Centered between LEFT and RIGHT
4. **Bottom:** BOTTOM margin spans full width below all
5. **Auto-spacing:** Marginalia prevents overlap by adjusting vertical positions

---

### Key Positioning Rules

| Scenario | Behavior | Result |
|----------|----------|--------|
| TOP only | Full width, occupies height | ✅ Simple |
| LEFT only | Narrow column, parallel to main | ✅ Simple |
| TOP + LEFT | LEFT starts **below** TOP | ✅ Sequential |
| TOP + LEFT + RIGHT | All vertically stacked, then parallel | ✅ Natural |
| ALL 4 margins | TOP → (LEFT + MAIN + RIGHT) → BOTTOM | ✅ Hierarchical |

---

### Configuration Best Practices

#### For 2-Margin Layout (LEFT + RIGHT)

```yaml
cv-layout:
  margin-left-width: "18mm"
  margin-right-width: "20mm"
  # TOP and BOTTOM auto-disabled if not used
```

#### For 3-Margin Layout (TOP + LEFT + RIGHT)

```yaml
cv-layout:
  margin-top-height: "6cm"
  margin-left-width: "18mm"
  margin-right-width: "20mm"
  # BOTTOM auto-disabled if not used
```

#### For Full 4-Margin Layout

```yaml
cv-layout:
  margin-top-height: "6cm"
  margin-bottom-height: "3cm"
  margin-left-width: "18mm"
  margin-right-width: "20mm"
  
  # Optional: control gap between margins and main
  margin-gutter: "0.5cm"
```

---

### Quarto Native vs Custom Classes for Margins

**Important Discovery:** Quarto natively only supports **`.column-margin`** (places content in right margin by default). There are no native `.column-margin-left`, `.column-margin-right`, or `.column-margin-top` classes.

#### Three Implementation Options

**Option A: Custom Classes (RECOMMENDED)** ✅

Create our own directional margin classes that marginalia understands:

```markdown
::: {.margin-top}
#| column: margin
### Header Section
:::

::: {.margin-left}
#| column: margin
### Contact Section
:::

::: {.margin-right}
#| column: margin
### Skills Section
:::

::: {.margin-bottom}
#| column: margin
### Footer Section
:::
```

**Advantages:**

- ✅ **Explicit & clear** — developer immediately knows which margin
- ✅ **Extensible** — easy to add more directional variants
- ✅ **Semantic** — `.margin-left` is self-documenting
- ✅ **Full control** — we define exactly how marginalia interprets each

**Implementation:** Define custom Pandoc filters or Typst functions to map these classes to marginalia directives.

---

#### Option B: Quarto Native with Config

Stick to Quarto's native `.column-margin` but add options:

```markdown
::: {.column-margin marginalia-side="left"}
### Contact
:::
```

**Issues:**

- ❌ Only one native class (`.column-margin`)
- ❌ Relies on custom attributes (non-standard)
- ❌ Less explicit

---

#### Option C: Hybrid (Avoid)

Mix of custom and native doesn't provide clarity.

---

#### Recommendation: **Option A** 

Use custom margin classes (`.margin-top`, `.margin-left`, `.margin-right`, `.margin-bottom`). They're:
- More explicit and maintainable
- Easier to style consistently
- Better aligned with the template's design goals

---

### Testing Questions for Marginalia Implementation

#### PRIORITY 1 — Margin Class Support (Critical)

- [ ] **How does marginalia map to Quarto's `.column-margin`?** Does it respect it or replace it?
- [ ] Can we create custom classes like `.margin-left`, `.margin-right` that marginalia recognizes?
- [ ] Do custom classes need Lua filter mapping or Typst function mapping?
- [ ] Does marginalia support `side: left` or similar parameter to control direction?
- [ ] Can we have 4-directional margin classes working simultaneously?

#### PRIORITY 2 — Layout & Positioning

- [ ] Does marginalia automatically handle sequential layout (TOP → LEFT/RIGHT → BOTTOM)?
- [ ] Can we force margin positioning with explicit parameters?
- [ ] How does marginalia handle conflicting vertical space requirements?
- [ ] If LEFT content is very tall, does it expand beyond RIGHT content height?
- [ ] Does marginalia auto-disable unused margins (e.g., if TOP margin height = 0)?
- [ ] Can we control gutter/gap between margins and main content?
- [ ] Does it work correctly with asymmetric layouts (LEFT present but no RIGHT)?

#### PRIORITY 3 — Styling & Content

- [ ] Do inline `style=` attributes work within margin divs?
- [ ] Can we apply per-margin colors/fonts independently?
- [ ] How do SVG icons render in narrow margin columns?
- [ ] Do R/Python plots with `#| column: margin` work inside marginalia?
- [ ] Can we use nested HTML/Typst styling in margins?

---

## Handling Quarto Native `.column-margin`

### The Problem

Quarto natively supports `.column-margin` for placing content in margins. Using custom margin classes (`.margin-left`, `.margin-right`, etc.) could create conflicts if users accidentally use both systems.

**Strategy:** Disable native `.column-margin` support in quarto-cv and gracefully redirect it to `.margin-right` to prevent confusion.

---

### Implementation: Auto-Redirect to `.margin-right`

#### Lua Filter Approach (Recommended)

Create a new Lua filter to intercept `.column-margin` usage:

**File: `_extensions/quarto-cv/margin-redirect.lua`**

```lua
-- Redirect deprecated .column-margin to .margin-right
-- This provides backward compatibility and helps users migrate

function Div(el)
  -- Check if div uses deprecated .column-margin class
  if el.classes:includes("column-margin") then
    -- Remove old class
    el.classes = pandoc.List(
      el.classes:filter(function(c) return c ~= "column-margin" end)
    )
    
    -- Add new class
    el.classes:insert("margin-right")
    
    -- Log warning for user awareness
    io.stderr:write(
      "[quarto-cv WARNING] .column-margin is deprecated. " ..
      "Automatically mapped to .margin-right. " ..
      "Consider updating your code.\n"
    )
  end
  
  return el
end
```

**Register in `_extension.yml`:**

```yaml
filters:
  - margin-redirect.lua  # Must run before other filters
  - icons.lua
  - timeline.lua
```

---

#### Configuration Option

In `_quarto.yml`:

```yaml
format:
  quarto-cv-typst:
    # Disable Quarto's native column-margin to avoid conflicts
    disable-native-column-margin: true
```

---

### User Documentation

Add to **README.md** — Migration Guide section:

#### Migration Guide: From Quarto Native Margins

If you're familiar with Quarto's `.column-margin`, here's how quarto-cv maps it:

| Quarto Native | quarto-cv | Direction | Behavior |
| --- | --- | --- | --- |
| `.column-margin` | `.margin-right` | Right | Default margin (auto-mapped) |
| N/A | `.margin-left` | Left | Left sidebar |
| N/A | `.margin-top` | Top | Header area |
| N/A | `.margin-bottom` | Bottom | Footer area |

**Good news:** If you accidentally write `.column-margin`, quarto-cv automatically maps it to `.margin-right` with a warning. No breaking changes! ✅

**Example:**

```markdown
::: {.column-margin}
This still works!
It will go to the right margin
:::
```

Gets automatically treated as:

```markdown
::: {.margin-right}
This still works!
It will go to the right margin
:::
```

---

### Recommended Best Practices

**Do:**
```markdown
::: {.margin-left}
#| column: margin
Contact info
:::

::: {.margin-right}
#| column: margin
Skills
:::
```

**Don't (but it still works):**
```markdown
::: {.column-margin}
This works but will show a warning
:::
```

---

## Color Best Practices

### ✅ Do's

- Use **2-3 main colors** maximum for professional look
- Use **color for hierarchy** (titles one color, body another)
- Apply colors **consistently** (same type = same color across sections)
- Use **margin-level colors** to visually distinguish left from right
- Keep **high contrast** for readability (dark text on light bg or vice versa)

### ❌ Don'ts

- Don't use **more than 5 colors** (looks chaotic)
- Don't color **every item** (defeats the purpose of highlighting)
- Don't use **low-contrast** combinations (#555555 on #777777)
- Don't change colors **randomly** per item (no visual logic)
- Don't mix **warm and cool** colors excessively (rose + purple + teal = messy)

### Color Palette Examples

**Monochrome Professional:**
```
Primary: #2563eb (blue)
Text: #1e293b (dark gray)
Accent: #64748b (slate)
```

**Dual-Color Balanced:**
```
Left: #2563eb (blue)
Right: #059669 (green)
Text: #1e293b (dark gray)
```

**Warm & Cool:**
```
Warm accent: #f59e0b (amber)
Cool accent: #06b6d4 (cyan)
Neutral: #1e293b (dark)
```

**Tech Bold:**
```
Primary: #7c3aed (purple)
Secondary: #ec4899 (pink)
Tertiary: #f59e0b (amber)
Dark: #0f172a
```

---

## Comparison: Current vs. Proposed

| Aspect | Current (2-Col) | Proposed (Marginalia) |
|--------|---|---|
| **Layout** | Fixed 30%/70% split | Flexible margins + auto main |
| **Sidebar definition** | YAML (100+ lines) | Markdown (cleaner) |
| **Margin control** | Sidebar-width only | 4 independent margins |
| **Figure placement** | Manual, limited | Native `column: margin` |
| **Text stacking** | Manual spacing | Auto (marginalia handles) |
| **Overlap handling** | Risk of overlap | Auto-prevented |
| **Quarto compatibility** | Custom extension | Native Quarto features |
| **Maintainability** | Complex YAML | Simple markdown |

---

## Migration Path

### Phase 1: Research & Testing
- [ ] Test marginalia with complex content (icons, colors, nested lists)
- [ ] Verify `column: margin` works with marginalia
- [ ] Test background colors and styling
- [ ] Confirm figures (R/Python/static) render correctly in margins

### Phase 2: Prototype
- [ ] Create test document with new structure
- [ ] Build Typst template for marginalia integration
- [ ] Test all content types in margins

### Phase 3: Implementation
- [ ] Update `typst-template.typ` for marginalia
- [ ] Update `typst-show.typ` to wire YAML to marginalia config
- [ ] Create example documents with new markdown structure
- [ ] Update README with new YAML + markdown format

### Phase 4: Theme Migration
- [ ] Migrate existing themes to new configuration
- [ ] Update advanced-example.qmd to showcase new features
- [ ] Ensure backward compatibility where possible

---

## Advantages of This Approach

### For Users
1. **Less YAML hell** — Simpler frontmatter, content in markdown
2. **More flexible** — Independent control of 4 margins
3. **Better for collaboration** — Easier to edit when in markdown format
4. **Native Quarto syntax** — Uses `column: margin`, not custom DSL
5. **Native figure support** — R/Python plots work directly in margins

### For Maintainers
1. **Cleaner architecture** — Less custom Lua/Typst logic
2. **Better alignment with Quarto** — Uses their standard features
3. **Easier to extend** — Add new sections without YAML restructuring
4. **Better examples** — Advanced-example.qmd is more readable

### For the Ecosystem
1. **Contributes back to Quarto** — Demonstrates marginalia usage
2. **Reusable patterns** — Can inspire other CV/resume templates
3. **Future-proof** — Aligns with Quarto 1.9+ direction

---

## Open Questions

1. **Color support in marginalia?** — Can we color margin backgrounds, or need Typst workaround?
2. **Content height limits?** — What's the maximum content we can fit in narrow margins?
3. **Photo rendering?** — Will SVG icons work properly in narrow margin context?
4. **Responsive behavior?** — How does marginalia handle narrow viewports (if applicable to PDF)?

---

## References

- [Marginalia Package (Typst Universe)](https://typst.app/universe/package/marginalia)
- [Article Layout (Quarto Docs)](https://quarto.org/docs/authoring/article-layout.html)
- [Quarto 1.9 Release Notes](https://quarto.org/docs/blog/posts/2026-03-24-1.9-release/)
- [Typst Custom Templates (Quarto)](https://quarto.org/docs/output-formats/typst-custom.html)
- [Related Issue #8](https://github.com/vgoupille/quarto-cv/issues/8) — Explore marginalia-based sidebar refactor
