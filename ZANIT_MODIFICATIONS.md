# Zanit — Modification Notice

**Modification date:** 2026-09-09
**Current Zanit version:** 1.2.1
**Upstream base:** chiaki-ng Canary commit `6547d8aed03503646fe1043512616e26c03fa9db`
**License:** GNU Affero General Public License v3, with the OpenSSL additional permission included by the upstream project.

Zanit is a modified build based on the open-source **chiaki-ng** project by Street Pea, which itself is based on **Chiaki** by Florian Märkl. Zanit is not endorsed, certified, or sponsored by Sony Interactive Entertainment.

## Main changes in Zanit 1.2.1

- User-facing application name is **Zanit**.
- Version metadata, Windows resource metadata and installer packaging updated to **1.2.1**.
- Integrated **DLSS 5 / ReShade runtime** with an in-app readiness indicator.
- Added a compact YouTube subscription button in the main header linking to the official Zanit channel.
- Completed the Brazilian Portuguese localization of the Steam artwork and PSN reminder dialogs, including all action buttons.
- Main screen shows **Zanit** / **Remote Play do seu jeito** and **v1.2.1 / by Enzo**.
- Windows/AppData identity uses **Zanit/Zanit**, including the log directory.
- The log folder button opens the local directory using `QDesktopServices` / `QUrl::fromLocalFile`.
- Startup promotional dialog is modal, centered relative to the main window, DPI-responsive, and can only be dismissed by one of its three explicit actions.
- Telegram offers link: `https://t.me/+jLyaJ9nZM1EzOTFh`.
- YouTube support link: `https://www.youtube.com/@Zanitzada`.
- The startup dialog includes a bundled QR code for the Telegram link.
- The **Geral** page was changed from content-sized/horizontally scrollable rows to a responsive three-column settings grid.
- The four stream-menu ComboBoxes now live in a responsive nested grid and the shortcut summary has its own bounded state column.
- The **Teclas** page now uses a responsive two-column (or one-column on narrower windows) mapping grid instead of three rigid cells sized for English labels.
- Long Portuguese analog-stick labels wrap within their own command column and no longer intrude into neighboring key buttons.
- `Reset All Keys` is localized as **Redefinir todas as teclas**.
- Common key names are localized for display without changing the stored key mapping.
- Updating a keyboard mapping now emits `controllerMappingChanged`, so the UI refreshes without destroying the live language binding.
- The **Controles** page now uses a responsive three-column option grid.
- The four directional/touch ComboBoxes use a responsive nested grid; the combination summary has a bounded state column.
- `Change Controller Mapping` and `Reset Controller Mapping` are localized as **Alterar mapeamento do controle** and **Redefinir mapeamento do controle**.
- Settings sidebar symbols were replaced by bundled SVG icons so they do not depend on font glyph availability.
- PS5 cards use a horizontal transparent PS5 asset derived from the user-provided console image, displayed with preserved aspect ratio and no stretching.
- Portuguese/English UI bindings remain dynamic through the existing Zanit language selector.

## Source and license obligations

This modified source remains under the GNU AGPLv3. If you distribute a compiled Zanit build, make the complete corresponding source for that exact build available under the same license and keep the original copyright/license notices.

The complete upstream license text and additional OpenSSL permission are preserved under `LICENSES/`.
