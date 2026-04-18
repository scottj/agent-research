# Rust on Windows GUI: framework/options survey (lean + native + performant)

Date: 2026-04-18

## Executive summary

If your top priorities are **lean binaries, native Windows behavior, and runtime performance**, the practical choices in 2026 are:

1. **`windows` / `windows-sys` (windows-rs) + hand-rolled Win32/WinUI architecture**
   - Best control/perf, most native, steepest complexity.
2. **`winsafe`**
   - Safe/idiomatic Win32 wrapper with higher-level GUI APIs; still very native and lean.
3. **`native-windows-gui` (NWG)**
   - Productive and native, but ecosystem freshness risk (project described as “done/final”).
4. **`fltk-rs`**
   - Lightweight and fast, but uses FLTK widgets (not pure Win32 look unless themed).
5. **`slint`**
   - Very strong performance story and small runtime; “native app” architecture but not raw Win32 controls.

Use **`tauri`/`wry`**, **`iced`**, or **`egui`** when dev speed/cross-platform UX matters more than strict native-control fidelity.

---

## Decision criteria used

- **Native fidelity on Windows** (real Win32/Windows controls vs custom-drawn/webview)
- **Performance profile** (CPU/GPU overhead, startup, memory)
- **Binary/runtime footprint**
- **Maintenance and ecosystem risk**
- **Complexity / development velocity**

---

## Option landscape

## 1) Lowest-level native path: `windows` / `windows-sys` (windows-rs)

**What it is**
- Microsoft Rust projection for Windows APIs (“Rust for Windows”).
- Calls Win32/WinRT directly from Rust.

**Why it fits lean/native/perf**
- Maximum control over API calls, threading model, message loops, COM, rendering stack.
- You can keep dependencies minimal and avoid framework overhead.

**Tradeoffs**
- More unsafe code surface and architecture work.
- You build more scaffolding yourself (state management, control composition, command routing).

**Evidence**
- docs.rs shows active release cadence through 2025 and direct “Rust for Windows” positioning.
- docs explicitly state `windows` + `windows-sys` can call any Windows APIs.

---

## 2) Native-safe Win32 abstraction: `winsafe`

**What it is**
- Safe, idiomatic wrappers for Win32 + higher-level GUI scaffolding.

**Why it fits**
- Keeps native Win32 control model while reducing unsafe boilerplate.
- Good middle-ground between raw `windows` and higher-level GUI kits.

**Tradeoffs**
- Smaller ecosystem than cross-platform frameworks.
- You still need to think in Win32 terms.

**Evidence**
- docs.rs description: “Windows API and GUI in safe, idiomatic Rust.”
- docs also note: for fully comprehensive coverage, fallback to `windows` crate.

---

## 3) Windows-focused toolkit: `native-windows-gui` (NWG)

**What it is**
- Lightweight wrapper over WinAPI controls with Rust-friendly API.

**Why it fits**
- Native widget model and generally low runtime overhead.
- Faster to ship than raw Win32.

**Risk/Tradeoff (important)**
- docs indicate the project is effectively finalized: “3rd and final version”, development “done”.
- Latest docs.rs crate version is old relative to the overall Rust GUI ecosystem.

**Use when**
- You want native controls and can accept maintenance/platform-evolution risk.

---

## 4) Lightweight cross-platform native widgets: `fltk-rs`

**What it is**
- Rust bindings for FLTK.

**Why it fits**
- Explicitly marketed as lightweight, can be statically linked for small self-contained binaries.
- Very good performance/footprint profile.

**Tradeoffs**
- Native-ish desktop app but not strict Win32 control fidelity.
- Brings C++/CMake toolchain considerations.

---

## 5) Performance-focused declarative toolkit: `slint`

**What it is**
- Declarative Rust UI toolkit with compiled UI runtime.

**Why it fits**
- Strong performance/footprint claims (machine-code compilation, very small runtime).
- Great when you want custom UI with high responsiveness.

**Tradeoffs**
- Not the same as using actual Win32 control set.
- Different UI paradigm from classic desktop control programming.

---

## 6) Cross-platform Rust UI frameworks: `iced`, `egui`

### `iced`
- Declarative Elm-style architecture; cross-platform and type-safe.
- Better for portability and maintainability than strict native Win32 look/perf tuning.

### `egui` / `eframe`
- Immediate-mode GUI, optimized for fast iteration and tooling apps.
- Usually excellent dev velocity; native fidelity is lower than Win32 controls.

---

## 7) Webview shell approach: `tauri` (`tao` + `wry`)

**What it is**
- Rust backend + web UI in system webview.
- On Windows it uses WebView2.

**Why teams pick it**
- Great productivity if your team likes web tech.
- Small-ish distribution versus Electron in many cases.

**Why it’s not top choice for strict requirement here**
- UI stack is webview-driven, not native Win32 controls.
- Runtime behavior depends on WebView2 presence/version dynamics.

---

## 8) Building blocks (not full GUI frameworks): `winit`, `tao`, `wry`

- `winit` is a low-level window/event layer (you still need rendering/widgets).
- `tao` and `wry` are often used as infrastructure under higher-level stacks.
- Useful for custom engines and very tailored desktop shells.

---

## Recommendations by scenario

### A) Maximum native fidelity + performance (Windows-first product)
**Pick:** `windows` + selective helper crates (`windows-sys`, COM helpers), optionally layer your own retained GUI architecture.

### B) Native fidelity with lower boilerplate
**Pick:** `winsafe`.

### C) Fastest path to native Win32 widgets (accepting maturity plateau risk)
**Pick:** `native-windows-gui`.

### D) Lean cross-platform desktop with strong performance
**Pick:** `fltk-rs` (more classic widgets) or `slint` (modern declarative/custom UI).

### E) If web stack is a hard requirement
**Pick:** `tauri`, while acknowledging non-Win32-native UI model.

---

## Practical architecture notes for lean/perf Windows Rust apps

- Prefer **message-driven design** and avoid over-abstracting hot paths.
- Keep **UI thread work minimal**; push heavy work to worker threads and post results.
- Minimize allocations in event/render paths.
- Be explicit about DPI-awareness and text/rendering choices.
- Benchmark startup, idle CPU, window resize, and list/tree virtualization early.

---

## Sources (primary)

- windows crate (docs.rs): https://docs.rs/crate/windows/latest
- winsafe crate docs: https://docs.rs/winsafe
- native-windows-gui crate docs: https://docs.rs/crate/native-windows-gui/latest
- fltk crate docs: https://docs.rs/fltk
- Slint site/docs: https://slint.dev/
- iced repository README: https://github.com/iced-rs/iced
- egui repository README: https://github.com/emilk/egui
- Tauri architecture docs: https://v2.tauri.app/es/concept/architecture/
- Tauri prerequisites (WebView2 on Windows): https://v2.tauri.app/start/prerequisites/
- winit repository README: https://github.com/rust-windowing/winit

