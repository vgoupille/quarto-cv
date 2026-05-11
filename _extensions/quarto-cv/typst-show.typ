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
        $if(sidebar-sections.style.category-weight)$"category-weight": "$sidebar-sections.style.category-weight$",$endif$
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
    $if(cv-theme.main-font)$ "main-font": "$cv-theme.main-font$", $else$$if(brand.typography.base.family)$ "main-font": "$brand.typography.base.family$", $endif$$endif$
    $if(cv-theme.title-font)$ "title-font": "$cv-theme.title-font$", $else$$if(brand.typography.headings.family)$ "title-font": "$brand.typography.headings.family$", $endif$$endif$
    $if(cv-theme.text-font)$ "text-font": "$cv-theme.text-font$", $else$$if(brand.typography.base.family)$ "text-font": "$brand.typography.base.family$", $endif$$endif$
    $if(cv-theme)$
      "sidebar": (
         $if(cv-theme.sidebar.title-color)$ "title-color": rgb("$cv-theme.sidebar.title-color$".replace("\#", "#")), $endif$
         $if(cv-theme.sidebar.text-color)$ "text-color": rgb("$cv-theme.sidebar.text-color$".replace("\#", "#")), $endif$
         $if(cv-theme.sidebar.accent-color)$ "accent-color": rgb("$cv-theme.sidebar.accent-color$".replace("\#", "#")), $endif$
         $if(cv-theme.sidebar.link-color)$ "link-color": rgb("$cv-theme.sidebar.link-color$".replace("\#", "#")), $endif$
         $if(cv-theme.sidebar.icon-color)$ "icon-color": rgb("$cv-theme.sidebar.icon-color$".replace("\#", "#")), $endif$
         $if(cv-theme.sidebar.photo-border-color)$ "photo-border-color": rgb("$cv-theme.sidebar.photo-border-color$".replace("\#", "#")), $endif$
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
