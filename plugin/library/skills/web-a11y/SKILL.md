---
name: web-a11y
description: Practical accessibility mechanics for web UI — semantic elements over div soup, keyboard operability, modal dialog focus management, ARIA rules, accessible forms, reduced motion, and contrast. Use when building or reviewing interactive components (modals, accordions, menus, tabs, toasts), when clickable divs or missing focus states appear, or when asked to audit a page for accessibility/WCAG.
---

# Web Accessibility Mechanics

Accessibility is mostly a consequence of using the right element. Most real-world failures
trace to a handful of patterns, listed here roughly in order of how often they break
things and how much they cost users.

## 1. The native element first

Before adding a `role`, ask whether an element already does the job. Native elements bring
keyboard handling, focus, state, and platform accessibility mapping for free — all of which
you would otherwise reimplement and get subtly wrong.

| Instead of | Use |
|---|---|
| `<div onclick>` | `<button type="button">` |
| `<div onclick>` that navigates | `<a href>` |
| `<div>` accordion | `<details>`/`<summary>`, or a `<button aria-expanded>` |
| custom modal | `<dialog>` with `showModal()` |
| `<span>` checkbox | `<input type="checkbox">` |
| `<div>` list of items | `<ul>`/`<li>` |
| styled `<div>` page regions | `<header> <nav> <main> <footer> <section>` |

**The clickable-div test:** if an element has an `onclick`, it must be reachable by Tab,
activate on both Enter and Space, show a visible focus ring, and announce a role. A
`<button>` does all four. A `<div>` with `tabindex="0"` plus a keydown handler does maybe
two, and you will forget Space.

If you genuinely must keep the div (layout constraints, existing CSS), the full
substitution is:

```html
<div role="button" tabindex="0"
     onclick="act()"
     onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();act();}">
```

That is strictly worse than `<button>`. Reset the button styling instead — it is three
lines: `background:none; border:0; font:inherit;`.

**Nesting rule:** an interactive element can never contain another interactive element. A
card that is one big `<button>` cannot hold a link inside it. Either make the whole card a
button, or make the card a plain container with one clear action inside.

## 2. Keyboard operability

Everything a mouse can do, a keyboard must do — in a sane order, with a visible indicator.

- **Never remove focus outlines without replacing them.** `outline: none` with no
  substitute is the most common accessibility regression in any codebase. Use
  `:focus-visible` so the ring appears for keyboard users and not on mouse click:

  ```css
  :focus-visible { outline: 2px solid var(--focus); outline-offset: 2px; }
  ```

  Give the ring enough contrast against *both* the element and the page background.

- **Never use positive `tabindex`.** `tabindex="1"` and up hijack the global tab order and
  break every page they touch. Only `0` (focusable, in DOM order) and `-1` (focusable by
  script only) are legitimate.

- **DOM order should match visual order.** CSS `order`, `row-reverse`, and grid placement
  can decouple them, leaving keyboard users jumping around the screen. If you reorder
  visually, reorder the DOM.

- **Provide a skip link** as the first focusable element on any page with navigation:

  ```html
  <a href="#main" class="skip-link">تخطَّ إلى المحتوى</a>
  ```

  Style it off-screen until `:focus`, not `display:none` (which makes it unfocusable).

- **Escape closes things.** Any dismissible overlay — modal, menu, popover, drawer —
  closes on Escape.

## 3. Modal dialogs — the four obligations

A modal that only toggles a CSS class is not a modal. Four things must happen:

1. **Focus moves in** when it opens — to the dialog, its first control, or its heading.
2. **Focus is trapped** while open — Tab from the last control wraps to the first,
   Shift+Tab from the first wraps to the last.
3. **Focus returns** to the element that opened it when it closes. Losing focus to
   `<body>` strands keyboard and screen-reader users at the top of the page.
4. **The background is inert** — not just visually covered. Content behind a modal must
   not be reachable by Tab or readable by a screen reader.

Native `<dialog>` + `showModal()` provides all four, plus Escape and the backdrop, with no
JS. Prefer it.

For a custom overlay, the markup contract is:

```html
<div class="overlay" role="dialog" aria-modal="true" aria-labelledby="dlg-title">
  <h2 id="dlg-title">…</h2>
```

`aria-modal="true"` tells assistive tech the rest of the page is unavailable — but it does
*not* stop Tab. You still need the trap, or the `inert` attribute on the page wrapper:

```js
document.getElementById('page').inert = true;   // on open
document.getElementById('page').inert = false;  // on close
```

Also restore body scroll on close, and remember that setting `body{overflow:hidden}` loses
the scroll position on iOS unless you save and restore it.

## 4. ARIA — the rules that matter

> The first rule of ARIA is: don't use ARIA. A native element with the right semantics
> beats any role.

When you do use it:

- **A role is a promise about keyboard behavior.** `role="tablist"` commits you to arrow-key
  navigation and roving tabindex. If you're not implementing that, don't claim the role.
- **State must be kept in sync in JS.** `aria-expanded`, `aria-selected`, `aria-checked`,
  `aria-pressed` are not decorative — a stale value is worse than none, because it actively
  lies. Update them in the same function that toggles the class.
- **`aria-label` overrides visible text** for screen readers. If they disagree, voice-control
  users saying the visible word can't activate the control. Keep the label a superset of
  the visible text, or use `aria-labelledby` to point at it.
- **Icon-only buttons need an accessible name.** `title` is not reliable. Use `aria-label`,
  and mark the icon `aria-hidden="true"` so it isn't announced twice.
- **Decorative images take `alt=""`** — empty, not missing. Missing `alt` makes screen
  readers read the filename.
- **Emoji used as UI need labels.** An emoji is read aloud by its full CLDR name
  ("clipboard", "woman technologist"). Wrap decorative emoji in
  `<span aria-hidden="true">`.

**Live regions** announce async changes — toasts, validation, counters, search results:

```html
<div role="status" aria-live="polite" aria-atomic="true"></div>
```

The region must exist in the DOM *before* the text is injected; creating and filling it in
the same tick often announces nothing. Use `polite` for almost everything; `assertive`
interrupts and is for genuine errors only.

## 5. Forms

- Every control has a `<label for>`, or is wrapped in one. Placeholder is **not** a label —
  it vanishes on input, fails contrast, and isn't reliably announced.
- Group related controls in `<fieldset>` with a `<legend>` (radio sets, address blocks).
- Errors: set `aria-invalid="true"`, point `aria-describedby` at the message, and put the
  message next to the field — not only in a summary at the top. Never signal errors with
  color alone.
- Use real `type` values (`email`, `tel`, `url`, `number`) — they bring the right mobile
  keyboard and free validation. Add `autocomplete` tokens (`name`, `email`, `tel`) so
  browsers and password managers can fill.
- Never disable the submit button as the only validation feedback; a disabled button gives
  no explanation and isn't focusable.

## 6. Motion, contrast, and zoom

**Respect reduced motion.** Vestibular disorders make large parallax, slides, and scale
animations genuinely painful. Honor the OS setting globally:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

Note this also has to disable `scroll-behavior: smooth` on `html`, which the blanket rule
above covers. Scroll-triggered reveal animations need a JS check too — if the reveal only
adds a class on intersection, elements must still be visible when animation is suppressed.
Make the *default* state visible and let JS add the animation, so a JS failure or a
reduced-motion setting leaves content readable rather than permanently transparent.

**Contrast minimums (WCAG AA):** 4.5:1 for body text, 3:1 for text ≥24px (or ≥19px bold),
3:1 for UI component boundaries and focus indicators. Check both themes independently —
a palette that passes in dark mode routinely fails in light. Muted secondary text on a
tinted background is where this usually breaks.

**Never convey information by color alone** — pair it with text, an icon, or a pattern.

**Zoom to 200%** must not clip content or force horizontal scrolling. This mostly means
avoiding fixed heights on text containers and using `rem` for type.

**Target size:** interactive targets at least 24×24px, 44×44px on touch surfaces.

## 7. Auditing an existing page

Fast static sweep for the usual offenders:

```bash
grep -nE 'onclick=' file.html | grep -vE '<(button|a) '   # clickable non-buttons
grep -nE 'outline:\s*(none|0)' file.css                    # killed focus rings
grep -nE 'tabindex="[1-9]' file.html                       # positive tabindex
grep -nE '<img(?![^>]*alt=)' file.html                     # missing alt
grep -nE 'role="dialog"' file.html                         # then verify focus trap
```

Then check by hand, in this order — it finds more than any automated tool:

1. **Unplug the mouse.** Tab through the whole page. Can you reach every control, see
   where you are at all times, operate everything, and escape every overlay?
2. **Zoom to 200%** and look for clipping.
3. **Force the OS into reduced-motion** and reload — is anything invisible or broken?
4. **Toggle light/dark** and re-check contrast on muted text.
5. Run axe DevTools or Lighthouse last. Automated tools catch roughly a third of issues
   and are silent on the ones that matter most — focus order, trap behavior, whether a
   label makes sense.

Fix in order of user impact: keyboard traps and unreachable controls first, missing names
second, contrast third, polish after.
