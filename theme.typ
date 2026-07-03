// Prinzipien: a touying theme following the design principles of
// Jean-luc Doumont's "Trees, maps, and theorems":
//
// - a (very) wide left margin, everything set flush against it
// - all sizes and positions coordinated from a few shared dimensions
// - one message per slide; the message is the slide title
// - one accent colour only, plus tints derived from it

#import "@preview/touying:0.7.4": *

/// Default slide function.
///
/// - config (dictionary): Per-slide touying configuration
///   (`config-xxx`, merge several with `utils.merge-dicts`).
///
/// - repeat (int, auto): Number of subslides. `auto` lets touying count.
///
/// - setting (function): Extra set/show rules for this slide.
///
/// - composer (function, array): Layout composer for multiple bodies.
///
/// - bodies (array): The contents of the slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

/// Prinzipien theme.
///
/// Apply with a show rule:
///
/// ```typst
/// #show: prinzipien-theme.with(
///   config-info(title: [One sentence to remember]),
/// )
/// ```
///
/// Fonts are set with plain `set text` / `show raw` rules, so they can be
/// overridden with your own rules after the show rule.
///
/// - aspect-ratio (string): Aspect ratio of the slides. Default is `16-9`.
///
/// - margin (ratio, length): Width of the reserved left margin area.
///   A ratio is resolved against the slide width. Default is `33%`.
///
/// - background (color): Background colour. Default is `#ffffff`.
///
/// - foreground (color): Foreground (text) colour. Default is `#221f21`.
///
/// - accent (color): The one accent colour. Default is `#f9ab1a`.
///
/// - suppressed (color): Colour for muted/suppressed content.
///   Default is `#7a7d80`.
#let prinzipien-theme(
  aspect-ratio: "16-9",
  margin: 33%,
  background: rgb("#ffffff"),
  foreground: rgb("#221f21"),
  accent: rgb("#f9ab1a"),
  suppressed: rgb("#7a7d80"),
  ..args,
  body,
) = {
  let page-args = utils.page-args-from-aspect-ratio(aspect-ratio)
  // For the known ratios touying returns a paper name only; resolve the
  // concrete dimensions of those papers so everything can be coordinated
  // from them.
  let (width: page-width, height: page-height) = {
    let papers = (
      "presentation-16-9": (width: 841.89pt, height: 473.56pt),
      "presentation-4-3": (width: 793.7pt, height: 595.28pt),
    )
    if "paper" in page-args {
      papers.at(page-args.paper)
    } else {
      page-args
    }
  }
  // The shared dimensions everything else is coordinated from:
  // the reserved left margin and one spacing unit.
  let margin-width = if type(margin) == ratio {
    margin * page-width
  } else {
    margin
  }
  let gap = 0.05 * page-height

  show: touying-slides.with(
    config-page(
      ..page-args,
      margin: (left: margin-width, right: gap, top: gap, bottom: gap),
      footer-descent: 0em,
    ),
    config-common(
      slide-fn: slide,
      slide-level: 2,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(
          font: "Noto Sans",
          size: 20pt,
          fill: self.colors.neutral-darkest,
        )
        show raw: set text(font: "Noto Sans Mono")
        set par(linebreaks: "optimized")

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-lightest: background,
      neutral-darkest: foreground,
      neutral-light: suppressed,
      primary: accent,
    ),
    config-store(
      margin-width: margin-width,
      gap: gap,
    ),
    ..args,
  )

  body
}
