# Rust GUI Options for Windows

Research date: 2026-04-17

## Bottom Line

For **Windows GUI apps in Rust with a preference for native code, low overhead, and high performance**, the best options are:

1. **`winsafe`** if you want the best balance of native Win32 controls and Rust-friendly ergonomics.
2. **raw `windows` / `windows-sys`** if you want maximum control, full Windows API access, and are comfortable working close to Win32/COM/DirectX.
3. **`native-windows-gui`** if you want a pragmatic Windows-only toolkit built on native controls and can accept that it is in a mature/final-state phase rather than a fast-moving ecosystem.

If you are willing to use **custom-rendered UI instead of real Windows widgets**, **Slint** is the strongest non-WebView option I found.

If you are willing to use a **WebView**, then **Tauri** is the lightest mainstream choice, but it is not a native-widget stack.

## Freshness Check

I did a second pass specifically on **which projects look likely to still matter in a few years**, using release recency, explicit project status, and organizational backing.

That changes the weighting:

1. **`windows` / `windows-sys`** moves to the top on long-term confidence.
2. **Slint** becomes more attractive than smaller Windows-only wrappers if custom-rendered UI is acceptable.
3. **`winsafe`** still looks alive and useful, but it has more niche-project risk than first-party or company-backed options.
4. **`native-windows-gui`** drops on future-momentum grounds because its latest crate release is old and the project says development is effectively done.

So if you want the recommendation optimized for both **Windows-native fit** and **probability of still being healthy in a few years**, my revised guidance is:

1. **raw `windows` / `windows-sys`**
2. **`winsafe`** if you specifically want native Win32 controls with a nicer Rust layer
3. **Slint** if custom-rendered native code is acceptable
4. **`native-windows-gui`** only if its current feature set already matches your needs and you are comfortable betting on a mostly-finished project

## Short Recommendation

If I were choosing today for a new Rust-first Windows desktop app:

- I would start with **raw `windows`** if long-term durability and full Windows API reach mattered most.
- I would use **`winsafe`** when I still wanted a classic native desktop app with menus, dialogs, list views, tree views, and other real Win32 controls, but with a friendlier Rust layer.
- I would drop to **raw `windows`** for APIs that higher-level wrappers do not expose, or if I wanted to build a custom-rendered UI on top of Direct2D/DirectComposition/Direct3D.
- I would choose **Slint** if cross-platform mattered and I still wanted native code and good performance without adopting a browser stack.
- I would choose **Tauri** only if the team specifically wanted HTML/CSS/JS for the UI.

## Decision Matrix

| Option | Native Windows widgets? | Rendering model | Windows-only? | Current read | Best for | Main downside |
|---|---|---|---|---|---|---|
| `windows` / `windows-sys` | Yes, if you build directly on Win32/UI APIs | OS APIs directly | Yes | Strong and foundational | Maximum control, performance, API reach | Most manual and lowest-level |
| `winsafe` | Yes | Native Win32 controls | Yes | Strong niche option | Safe-ish, idiomatic Rust over Win32 | Smaller ecosystem than raw `windows` |
| `native-windows-gui` | Yes | Native Win32 controls | Yes | Mature/final-state | Fastest path to classic Windows UI | Lower long-term momentum |
| Slint | No, Windows uses Fluent-styled widgets | Custom-rendered native code | No | Active and compelling | Modern UI without WebView | Not real Win32 widgets |
| FLTK-rs | No | FLTK toolkit | No | Practical lightweight option | Tiny binaries, fast startup, simple deployment | Visual style is not truly native Windows |
| egui / eframe | No | Immediate-mode custom rendering | No | Very active | Tools, editors, debug UIs, graphics-heavy apps | Officially not for native look |
| iced | No | Custom rendering via `wgpu` / `tiny-skia` | No | Promising but still experimental | Elm-style reactive apps | Experimental, not native widgets |
| Tauri | No | WebView (`WebView2` on Windows) | No | Very active | Lightweight desktop apps with web UI | Browser-based UI model |
| Dioxus Desktop | No | WebView via Tauri/Wry/Tao | No | Active | Rust-heavy React-like DX with desktop target | Still a WebView path |
| Xilem | No | Native compiled custom renderer | No | Very interesting but early | Forward-looking high-performance Rust UI | Experimental |

## Sustainability Read

### Very high confidence

#### `windows` / `windows-sys`

- First-party Microsoft project.
- Microsoft Learn still points Rust developers directly to `windows-rs`.
- Docs.rs shows `windows 0.62.2` released on **2025-10-06**.

This is the safest bet if you care most about something still being relevant in a few years.

### High confidence

#### Slint

- Active releases and active organization presence.
- Docs.rs build page shows `slint 1.16.0` building on **2026-04-16**.
- The `slint-ui` GitHub organization presents as a company-backed project rather than a hobby crate.

This is the strongest long-lived option among the non-WebView, non-Windows-widget stacks.

#### Tauri

- Very large ecosystem and contributor base.
- Docs.rs shows `tauri 2.10.3` released on **2026-03-04**.
- Strongest staying power among WebView-based Rust desktop stacks.

### Medium confidence

#### `winsafe`

- Recent releases are a strong signal: `0.0.23` on **2025-03-01**, `0.0.24` on **2025-06-01**, `0.0.25` on **2025-07-01**, `0.0.26` on **2025-10-01**, and `0.0.27` on **2026-01-01**.
- The project is clearly alive.
- However, it is still much smaller and more niche than `windows`, Slint, or Tauri.

So my read is: very plausible for the next few years, but with more bus-factor risk.

#### egui / eframe

- Very active releases.
- Docs.rs shows `eframe 0.34.1` released on **2026-03-27**.
- Large ecosystem and many contributors.

I would trust it to still exist and matter in a few years. It just does not match the native-widget goal.

#### Dioxus Desktop

- Very active release train.
- Docs.rs shows `dioxus-desktop 0.7.5` on **2026-04-06**.
- The Dioxus organization describes itself as a small full-time team.

Again, probably durable enough, but it is still a WebView-oriented answer.

### Lower confidence for new bets

#### `native-windows-gui`

- Latest crate release on docs.rs is `1.0.13` from **2022-09-05**.
- The project explicitly says development is "done" and future development will happen in other libraries.

That does not mean it is bad. It means the right framing is:

- good if its current feature set already solves your problem;
- weaker if you want ecosystem momentum and strong evidence of future evolution.

#### iced

- Active project and meaningful community.
- But the project still explicitly says it is **experimental**.

So I expect it to still exist, but I am less confident in its long-term API stability than in `windows`, Slint, or Tauri.

## Best Native-Feeling Rust Paths

### 1. `winsafe`

Why it stands out:

- The project explicitly targets both **Windows API bindings** and **high-level native Win32 GUI abstractions**.
- It stays close to Windows concepts while still being more idiomatic than raw FFI.
- It supports native controls and resource-file-driven workflows, which is useful if you want traditional Windows app structure.

When to choose it:

- You want a **real Windows desktop app**, not a cross-platform abstraction.
- You care about **native control behavior**, smaller runtime overhead, and predictable Windows integration.
- You want something more ergonomic than raw `windows`, but do not want to leave the Win32 model.

### 2. Raw `windows` / `windows-sys`

Why it stands out:

- Microsoft positions `windows` as the direct Rust projection for the Windows API, including classic Win32 and newer UI-related APIs.
- This is the most future-proof route for **full API coverage**.
- It gives you the cleanest path if you want to combine Win32 windows with Direct2D, DirectComposition, Direct3D, notifications, shell integration, package identity, or other Windows-specific features.

When to choose it:

- You want the **most native** and **least abstracted** solution.
- You are comfortable owning more unsafe/boilerplate code.
- You may need APIs that wrappers do not cover.

### 3. `native-windows-gui`

Why it stands out:

- It is explicitly a **light wrapper over WinAPI** and emphasizes **small compile times** and **minimal resource usage**.
- It is very direct if the app fits classic desktop UI patterns.

When to choose it:

- You want to ship a Windows-only desktop app quickly.
- You want native controls with less ceremony than raw Win32.

Caution:

- The project describes itself as the **final version** and **mature**, which is good for stability but not ideal if you want a rapidly evolving ecosystem.

## Native Code, But Not Native Widgets

### Slint

This is the most compelling option if you want:

- native code,
- a declarative UI model,
- strong performance,
- no browser runtime,
- and potentially cross-platform portability.

Important nuance:

- On Windows, Slint's default `native` style maps to **Fluent styling**, not actual Win32 controls.
- It is therefore **Windows-like**, not literally a thin wrapper over the OS widget toolkit.

My take:

- If your real priority is **lightweight native code** more than **true native widgets**, Slint is a very strong choice.
- If your priority is specifically **real Win32 control behavior**, it is not the top choice.

### FLTK-rs

Good points:

- Very small binaries.
- Fast startup.
- Statically linked single-executable deployment is straightforward.

Tradeoff:

- It is lightweight and practical, but it is still **FLTK's own widget toolkit**, not Windows-native UI.

## Popular Rust GUI Stacks That Do Not Match The Native-Widget Preference

### egui / eframe

Best for:

- internal tools,
- editors,
- inspectors,
- dashboards,
- apps where immediate-mode UI is a feature.

Why it misses the preference:

- The project itself says that if you want a GUI that looks native, **egui is not for you**.

### iced

Best for:

- developers who like Elm-style architecture and reactive patterns.

Why it misses the preference:

- It uses custom renderers rather than native Windows widgets.
- The project still describes itself as **experimental**.

## WebView Routes

### Tauri

What it does well:

- Much lighter than Electron.
- Strong packaging story.
- Small app sizes for a browser-based desktop architecture.

Why it misses the preference:

- It is still a **web UI inside a native shell**, not a native widget toolkit.

### Dioxus Desktop

What it does well:

- Rust-heavy component model.
- Small-ish desktop apps.

Why it misses the preference:

- Its own docs say it renders through the platform's **native WebView** and is built on **Tauri/Wry/Tao**.

## Lower-Level Building Blocks

These are useful if you want to assemble your own stack instead of adopting a full framework:

- **`winit`**: window creation and event loop management, but not a GUI toolkit by itself.
- **`wry`**: WebView layer.
- **`tao`**: application window/event loop library often paired with `wry`.
- **`windows` / `windows-sys`**: foundational Windows API access.

## Projects To Watch Or Avoid

### Watch: Xilem

- Very interesting design.
- Native compiled.
- Strong performance ambition.
- Still experimental.

I would watch it, not bet a production Windows app on it yet unless experimentation is the goal.

### Avoid for new work: Druid

- The project is explicitly marked **UNMAINTAINED** and discontinued.

### Not really ready for this use case: GPUI

- GPUI looks promising for high-performance Rust UI work, but its current docs still say to use it on **macOS or Linux**.
- That makes it a poor answer for a Windows GUI app choice today.

## WinUI 3 Note

Microsoft's **official modern Windows UI stack** is WinUI 3, but the current first-party WinUI docs present it as a framework for **C#/.NET or C++ with XAML**.

Inference from the sources:

- Rust is supported well for calling Windows APIs and for Windows packaging workflows.
- Rust is **not** presented as a first-class WinUI 3 app-authoring language today.
- So if the goal is a **pure-Rust** Windows GUI app, WinUI 3 is not currently the cleanest primary path.

## Final Ranking For This Specific Preference

For "native, light, performant" on Windows with Rust:

1. **`winsafe`**
2. **raw `windows` / `windows-sys`**
3. **`native-windows-gui`**
4. **Slint** if custom-rendered native code is acceptable
5. **FLTK-rs** if tiny binaries matter more than native Windows look

## Final Ranking If Longevity Matters More

If "still likely to be healthy in a few years" is weighted heavily, I would rank them this way:

1. **raw `windows` / `windows-sys`**
2. **Slint**
3. **`winsafe`**
4. **Tauri**
5. **`native-windows-gui`**

## Sources

- [Microsoft Learn: Rust for Windows, and the `windows` crate](https://learn.microsoft.com/en-us/windows/dev-environment/rust/rust-for-windows)
- [Microsoft Learn: WinUI 3](https://learn.microsoft.com/en-us/windows/apps/winui/winui3/)
- [Microsoft Learn: Using `winapp` CLI with Rust](https://learn.microsoft.com/en-us/windows/apps/dev-tools/winapp-cli/guides/rust)
- [`windows` crate on docs.rs](https://docs.rs/crate/windows/latest)
- [`windows-rs` releases on GitHub](https://github.com/microsoft/windows-rs/releases)
- [`native-windows-gui` GitHub README](https://github.com/gabdube/native-windows-gui)
- [`native-windows-gui` crate on docs.rs](https://docs.rs/crate/native-windows-gui/latest)
- [`winsafe` docs](https://rodrigocfd.github.io/winsafe/winsafe/)
- [`winsafe` crate on docs.rs](https://docs.rs/crate/winsafe/latest)
- [Slint widget styles docs](https://docs.slint.dev/latest/docs/slint/reference/std-widgets/style/)
- [Slint backends and renderers docs](https://docs.slint.dev/latest/docs/slint/guide/backends-and-renderers/backends_and_renderers/)
- [`slint` crate on docs.rs](https://docs.rs/crate/slint/latest)
- [Slint GitHub organization](https://github.com/slint-ui)
- [`egui` GitHub README](https://github.com/emilk/egui)
- [`eframe` crate on docs.rs](https://docs.rs/crate/eframe/latest)
- [`iced` GitHub README](https://github.com/iced-rs/iced)
- [`iced` crate on docs.rs](https://docs.rs/crate/iced/latest)
- [FLTK-rs project site](https://fltk-rs.github.io/fltk-rs/)
- [Tauri site](https://tauri.app/)
- [`tauri` crate on docs.rs](https://docs.rs/crate/tauri/latest)
- [`dioxus-desktop` docs](https://docs.rs/dioxus-desktop/latest/dioxus_desktop/)
- [Dioxus Labs GitHub organization](https://github.com/DioxusLabs)
- [`xilem` GitHub README](https://github.com/linebender/xilem)
- [`druid` GitHub README](https://github.com/linebender/druid)
- [`gpui` docs](https://docs.rs/gpui/latest/gpui/)
