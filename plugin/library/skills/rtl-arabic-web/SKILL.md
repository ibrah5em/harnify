---
name: rtl-arabic-web
description: Building or reviewing right-to-left web UI, especially Arabic-first sites. Covers CSS logical properties, bidi text handling (mixed Arabic/Latin, numbers, phone numbers), Arabic typography rules, what to mirror and what never to mirror, digit systems, and RTL-specific JS pitfalls. Use when a page has dir="rtl", lang="ar"/"he"/"fa"/"ur", Arabic content, or when adding RTL support to an LTR layout.
---

# RTL & Arabic Web

RTL is not "LTR with the text moved over". Direction is a layout axis, and Arabic is a
cursive script with its own typographic rules. Most RTL bugs come from three habits:
hardcoding `left`/`right`, letting the bidi algorithm run unbounded on mixed content, and
applying Latin typographic tricks to a script that doesn't have them.

## 1. Logical properties, always

Physical properties break the moment direction flips. Use the logical equivalent so one
stylesheet serves both directions with no `[dir="rtl"]` override block.

| Never | Always |
|---|---|
| `margin-left` / `margin-right` | `margin-inline-start` / `margin-inline-end` |
| `padding-left` / `padding-right` | `padding-inline-start` / `padding-inline-end` |
| `left` / `right` (offsets) | `inset-inline-start` / `inset-inline-end` |
| `border-left` / `border-right` | `border-inline-start` / `border-inline-end` |
| `border-radius: a b c d` | `border-start-start-radius` etc., or keep symmetric |
| `text-align: left` / `right` | `text-align: start` / `end` |
| `float: left` / `right` | `float: inline-start` / `inline-end` |
| `width` / `height` (when flow-relative) | `inline-size` / `block-size` |

Flexbox and grid are already direction-aware: `flex-direction: row` and grid column order
flip automatically under `dir="rtl"`. Do not "fix" them with `row-reverse` — that
double-flips and breaks LTR. Only reach for `row-reverse` when you want the order reversed
*relative to* reading direction in both directions.

`gap`, `place-items`, and `justify-content: start/end` are all safe. `justify-content:
left/right` is not — it is physical.

**The exception:** `box-shadow`, `text-shadow`, `translate`, and `background-position` take
physical coordinates with no logical form. A shadow offset `4px 4px` leans the same
physical way in both directions. If the shadow implies a light source tied to the layout,
flip the x-offset under `[dir="rtl"]`. For ambient shadows (`0 4px 12px`), leave it.

## 2. Bidi: isolate every foreign run

The Unicode bidi algorithm reorders text at render time, and it does not know where your
data ends. Any Latin string dropped into Arabic — a username, a URL, a version number, a
brand — can drag adjacent punctuation to the wrong end.

The classic break: `<span>مرحبا Noor!</span>` renders the `!` on the wrong side, and
`اسم المستخدم: noor_hasaki` can display the underscore-name detached from its label.

**Fix — wrap untrusted or mixed runs in `<bdi>`:**

```html
<p>المستخدم: <bdi>noor_hasaki</bdi></p>
<p>الإصدار <bdi dir="ltr">v2.1.0</bdi></p>
```

`<bdi>` defaults to `dir="auto"`, which picks direction from the first strong character —
exactly right for user-generated content whose language you don't know at build time.

For CSS-only isolation on a container: `unicode-bidi: isolate` (or `isolate-override` to
force a direction). Avoid `unicode-bidi: bidi-override` — it disables the algorithm rather
than scoping it, and mangles genuinely mixed strings.

**Neutral characters are the trap.** Digits, punctuation, spaces, and symbols have no
inherent direction; they inherit from the surrounding run. Two Latin words separated by a
comma inside Arabic will place that comma unpredictably. When you can't wrap in `<bdi>`,
the marks `&rlm;` (U+200F) and `&lrm;` (U+200E) pin a neutral character to a direction.

**Never mirror these, even though they look symmetric:** phone numbers, times (`10:30`),
dates in numeric form, IP addresses, file paths, math expressions, and code. They are
LTR sequences that happen to be made of neutrals and digits. Give them
`dir="ltr"` explicitly:

```html
<span class="phone" dir="ltr">+963 964 501 674</span>
```

Without it, a leading `+` jumps to the far end and the number reads wrong.

## 3. Arabic typography

Arabic is cursive — letters join. Latin display tricks either do nothing or actively
destroy legibility.

- **`letter-spacing` is forbidden.** It severs the joins between letters, turning words
  into disconnected glyphs. This is the single most damaging RTL CSS mistake. Set
  `letter-spacing: 0` explicitly if a global reset or a Latin-oriented design system
  applied one.
- **`text-transform: uppercase` does nothing.** Arabic has no letter case. Harmless but
  pointless — and if the design depends on the visual weight of caps, that intent is lost
  and needs solving another way (weight, size, color).
- **`font-style: italic` produces synthetic oblique**, which looks broken in Arabic. Use
  weight or color for emphasis instead.
- **Line height must be larger.** Arabic has tall ascenders and deep descenders, and
  diacritics sit above and below. `line-height: 1.4` that reads fine in Latin clips in
  Arabic. Use **1.7–2.0** for body text, and never a unitless value below 1.5.
- **Font size runs slightly larger.** At identical `font-size`, Arabic's x-height-equivalent
  reads smaller and denser. Bump Arabic body text roughly 1–2px over the Latin equivalent.
- **Justified text is risky.** Arabic traditionally justifies via *kashida* (glyph
  elongation), which browsers do poorly. `text-align: justify` produces ugly word-space
  rivers. Prefer `text-align: start`.
- **Don't fake bold.** Load a real heavy weight; synthesized bold smears the joins.

**Typefaces that actually work for Arabic UI:** Tajawal, Cairo, IBM Plex Sans Arabic, Noto
Sans Arabic / Noto Kufi Arabic, Rubik (has Arabic), Almarai, Readex Pro. Verify the weights
you specify genuinely exist in the family — a missing 800 silently synthesizes.

Always give the Arabic family a real fallback chain, and let the system Arabic font sit
ahead of the generic:

```css
font-family: 'Tajawal', 'Segoe UI', Tahoma, Arial, sans-serif;
```

## 4. Digits: pick a system and hold it

Arabic content uses either Western digits (`0-9`) or Arabic-Indic digits (`٠١٢٣٤٥٦٧٨٩`),
and mixing them in one interface looks careless.

```js
new Intl.NumberFormat('ar-EG').format(2005)          // "٢٬٠٠٥"  Arabic-Indic
new Intl.NumberFormat('ar-EG-u-nu-latn').format(2005) // "2,005"  Western
new Intl.NumberFormat('ar').format(2005)              // locale-dependent — avoid
```

**Years are not quantities.** `2005` formatted as a number becomes `٢٬٠٠٥` with a
thousands separator, which is wrong for a year. Format years with no grouping:

```js
new Intl.NumberFormat('ar-EG', { useGrouping: false }).format(2005) // "٢٠٠٥"
```

A CSS-only route exists via `font-feature-settings: "anum"`, but support is inconsistent
across families — prefer formatting the value in JS so the DOM text is correct for
copy-paste, screen readers, and search.

Keep identifiers, phone numbers, prices with currency codes, and anything the user might
copy in Western digits unless the design explicitly calls for Arabic-Indic.

## 5. Mirror, or don't

Flipping the layout does not mean flipping every glyph.

**Mirror** — anything whose meaning is tied to reading direction:
- Directional arrows: back/forward, next/previous, breadcrumb chevrons, carousel controls
- Progress bars and steppers (progress grows toward the reading edge)
- Text-alignment icons, indent/outdent, list bullets
- Speech bubble tails, drawer/sidebar slide direction
- `→` in copy: use `←` in RTL, or better, drop directional arrows from text entirely

**Never mirror** — meaning is absolute, not directional:
- Logos and brand marks
- Media transport controls (play ▶ always points right — it's a tape metaphor, universal)
- Clocks and anything clockwise (undo/redo curves, spinners, refresh)
- Checkmarks, question marks in icon form
- Charts with a time axis where the convention is left-to-right (verify against the
  audience — Arabic charts vary; ask rather than assume)
- Images of real objects, screenshots, maps
- Code blocks, terminal output

Mirror with `transform: scaleX(-1)` scoped to direction:

```css
[dir="rtl"] .icon-arrow { transform: scaleX(-1); }
```

For inline SVG you control, prefer authoring a real RTL variant when the flipped version
would look wrong (asymmetric shading, embedded text).

## 6. JS and DOM pitfalls

- **`element.scrollLeft` is negative in RTL** in Firefox and Safari, and counts down from
  zero in Chrome. Never compare it against a positive number. Use `scrollIntoView()`, or
  read `Math.abs(el.scrollLeft)` when you must.
- **`getBoundingClientRect()` returns physical coordinates.** `rect.left` is the visual
  left in both directions — it is not the start edge. Compute the start edge from
  direction.
- **Keyboard arrows.** In an RTL context, ArrowLeft moves *forward* through a horizontal
  list, ArrowRight moves back. Roving-tabindex widgets (tabs, toolbars, menubars) must
  invert their handling or navigation feels reversed.
- **Swipe/drag gestures** in carousels need the same inversion.
- **Third-party widgets** — maps, charts, date pickers, editors — usually ignore
  `dir="rtl"`. Check each one and wrap in an LTR island (`dir="ltr"`) if it can't cope,
  rather than fighting it.
- **`Intl.DateTimeFormat`** with an Arabic locale gives Arabic month names and the right
  digit system for free. Don't hand-roll month arrays.

## 7. Setup and review checklist

Root element carries both attributes — direction and language are separate concerns, and
screen readers need the language to pick the right voice:

```html
<html lang="ar" dir="rtl">
```

Set `lang` on any run that switches language, so pronunciation stays correct:

```html
<p>ندرّس لغة <span lang="en">Python</span> في السنة الثانية.</p>
```

Before shipping, verify:

- [ ] No `left:`/`right:`/`margin-left`/`padding-right` etc. left in the stylesheet
      (`grep -nE '(margin|padding|border)-(left|right)|[^-]\b(left|right):'`)
- [ ] No `letter-spacing` applied to Arabic text
- [ ] `line-height` ≥ 1.7 on Arabic body copy
- [ ] Phone numbers, emails, URLs, and code carry `dir="ltr"`
- [ ] Digit system consistent site-wide; years have no thousands separator
- [ ] Directional icons mirror; logos and media controls do not
- [ ] Layout checked at 360px — Arabic words don't hyphenate and wrap in longer chunks
- [ ] Keyboard arrow navigation feels forward-is-left in horizontal widgets
- [ ] Real Arabic content used for testing, not lorem ipsum — string lengths differ
      substantially from English and break tight layouts

When adding RTL to an existing LTR site, converting to logical properties is almost always
less total work than maintaining a parallel `[dir="rtl"]` override sheet, and it can't
drift out of sync.
