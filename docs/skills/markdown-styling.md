# Markdown Styling

## No explicit horizontal rules

Do not add standalone `---` horizontal rules as section separators. They render too thick in the terminal and most viewers. If the source material has a structural `<hr>`, preserve it — but don't inject new ones.

## Box-drawing: single only, no double

Use single-line box-drawing characters (`┌`, `─`, `┐`, `│`, `└`, `┘`, `├`, `┤`, `┬`, `┴`, `┼`) for diagrams and code-block art. Avoid double-line variants (`╔`, `═`, `╗`, `║`, `╚`, `╝`, `╠`, `╣`, `╦`, `╩`, `╬`) — they render too thick and look heavy in markdown.

## Verify box-drawing alignment

After drawing or editing a box diagram, verify:

1. **All lines are the same width** — count the total character length of each line in the code block. A single line off by one breaks the whole box.
2. **Arrow connectors align** — the center T-junction (`┬`, `┴`, `┼`) on the box edge must line up with the vertical pipe (`│`) and arrow (`▼`, `▲`) between boxes. Count spaces from the left edge.
3. **Inner padding is consistent** — headers should be roughly centered, list items uniformly indented.
4. **No stray characters** — verify box corners match: every `┌` has a `┐`, every `└` has a `┘`, every `├` has a corresponding `┤`.

Run a quick length check on the diagram lines before committing.

After centering, verify by eye that the right border (`┐`, `┤`, `┘`) stacks vertically across all lines — if any line's border is shifted left or right, the padding is wrong. A common gotcha: a 12-char header in a 22-wide box needs 5+12+5 padding, not 4+12+6.

## General preferences

- Prefer clean prose over decorative dividers.
- Use headings, lists, and spacing for visual separation instead of rules.
- Keep markdown readable in raw form, not just when rendered.
