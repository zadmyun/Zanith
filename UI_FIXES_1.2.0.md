# Zanith 1.2.0 — UI Fixes

This package contains the UI/layout corrections requested after testing the first Zanith 1.2.0 build.

## Root causes addressed

- General and Controllers used content-sized `RowLayout`s and `ComboBox.WidestText`, so Portuguese labels widened rows beyond the content card.
- Keys used a 3-column grid where each cell contained a fixed 200 px label + 170 px key button, which was sized around English strings and caused translated labels to overlap neighboring cells.
- Several requested Portuguese strings were still hardcoded English instead of using the Zanith runtime language binding.
- The startup promotion used `Overlay.overlay` dimensions during early startup, while the overlay could still be unlaid-out, yielding negative/incorrect popup coordinates and an oversized dialog.
- Sidebar icons depended on Unicode glyphs, which vary by font and could render tiny or missing.

## Structural fixes

- General: vertical-only Flickable, bounded responsive three-column settings grid, nested 4/2-column shortcut grid, bounded shortcut summary column.
- Keys: responsive 2-column mapping grid (1 column when narrow), word-wrapped command labels, fixed-width key buttons, no horizontal scrolling.
- Controllers: responsive three-column settings grid plus nested 4/2-column directional shortcut grid.
- Promotion: modal popup sized from the main root window in logical pixels, centered from `root.width/root.height`, delayed until the main UI has rendered, `Popup.NoAutoClose`, ESC blocked, and re-open protection if closed without one of the 3 choices.
- PS5: transparent horizontal asset using `Image.PreserveAspectFit` so it cannot be stretched or flattened.
- Sidebar: bundled SVG icons instead of font glyphs.

## Localization fixes

Brazilian Portuguese additions include:

- Reset All Keys → Redefinir todas as teclas
- Change Controller Mapping → Alterar mapeamento do controle
- Reset Controller Mapping → Redefinir mapeamento do controle
- D-Pad directions → Direcional para cima/baixo/esquerda/direita
- Left/Right Stick directions → Analógico esquerdo/direito para ...
- Common key display names such as arrows and Space
- Existing General / Video / Stream / Audio & Network / Controllers / Profiles bindings remain dynamic for English and Português (Brasil).

## Local validation performed in this environment

- QML delimiter/bracket sanity check passed for `SettingsDialog.qml`, `PromoDialog.qml`, `Main.qml` and `MainView.qml`.
- Resource `.qrc` XML parsed successfully and all referenced resource files exist.
- Layout sizing was checked at representative logical window widths and at 100%, 125% and 150%-style logical resolutions; General/Controllers switch the four-combo rows from 4 columns to 2 columns when needed, and Keys switches from 2 columns to 1.
- Full Windows build/run was not possible in this Linux execution environment because the Windows/MSYS2/Qt toolchain and project dependencies are not available here. The included Windows build script is the intended final validation path.
