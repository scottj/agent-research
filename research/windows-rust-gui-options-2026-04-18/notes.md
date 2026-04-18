# Notes - Rust Windows GUI options research

## 2026-04-18
- Created investigation folder per AGENTS.md instructions.
- Goal: compare frameworks/options for building Windows GUI apps in Rust, prioritizing lean native performant code.
- Plan: gather current frameworks, check maintenance status and architecture, then recommend based on constraints.
- Tried collecting crate metadata via crates.io API using Python requests; blocked by proxy (403 tunnel). Switched to using web search snippets and official docs pages instead.
- Gathered current source data from official docs and repos:
  - windows crate docs.rs shows latest version 0.62.2 and release timeline through 2025.
  - winsafe docs describe safe idiomatic Win32 + high-level GUI wrappers.
  - native-windows-gui docs show latest 1.0.13 (2022-09-05) and project marked essentially done/final API.
  - fltk docs position it as lightweight and statically-linkable for small fast apps.
  - slint site claims machine code compilation and very small runtime footprint (<300KiB RAM runtime).
  - iced and egui GitHub READMEs confirm cross-platform orientation and immediate/declarative models.
  - tauri docs confirm use of WRY/TAO and WebView2 requirement on Windows.
  - winit README confirms it is low-level window/event layer, not full widgets.
- Decided to structure recommendations by “native-ness + performance + maintenance risk” for Windows-focused Rust apps.
- Drafted README report with ranking by native fidelity/performance and scenario-based recommendations.
- Included primary-source links and explicit caveats about maintenance risk for NWG and webview tradeoffs for Tauri.
