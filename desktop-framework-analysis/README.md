# Cross-Platform Desktop Framework Analysis (2026)

<!-- AI-GENERATED-NOTE -->
> [!NOTE]
> This is an AI-generated research report. All text and code in this report was created by an LLM (Large Language Model). For more information on how these reports are created, see the [main research repository](https://github.com/scottj/agent-research).
<!-- /AI-GENERATED-NOTE -->

**Date:** 2026-02-27
**Task:** Evaluate options for building cross-platform desktop applications targeting macOS and Windows

---

## Summary

This report analyzes the major cross-platform desktop frameworks available in early 2026, with a focus on bundle size, performance, native look & feel, language requirements, licensing, and ecosystem maturity.

---

## Frameworks Evaluated

| Framework     | Language       | Bundle Size    | Native UI        | Performance | License              |
|---------------|----------------|----------------|------------------|-------------|----------------------|
| Electron      | JS/TS          | 100–200 MB+    | No (Chromium)    | Poor        | MIT                  |
| Tauri v2      | Rust + Web     | 1–10 MB        | No (WebView)     | Good        | MIT / Apache-2.0     |
| Flutter       | Dart           | 10–30 MB       | No (Custom)      | Good        | BSD-3                |
| Qt 6          | C++ / Python   | Varies         | Yes              | Excellent   | LGPL / Commercial    |
| .NET MAUI     | C#             | 30–80 MB       | Yes (partial)    | Good        | MIT                  |
| Avalonia UI   | C#             | 15–40 MB       | No (Custom/Skia) | Very Good   | MIT                  |
| wxWidgets     | C++ / Python   | 5–20 MB        | Yes (truly)      | Excellent   | wxWindows (LGPL-like)|
| JavaFX        | Java           | 40–80 MB       | No (Custom)      | Moderate    | GPL / Commercial     |
| Wails         | Go + Web       | 5–15 MB        | No (WebView)     | Good        | MIT                  |
| Neutralinojs  | JS/TS          | 1–5 MB         | No (WebView)     | Good        | MIT                  |

---

## Framework Deep-Dives

### Electron
- Bundles **Chromium + Node.js** — the runtime is the framework
- Ships ~6 major versions/year, tracks every other Chromium release
- Latest stable (early 2026): v39–41, Chromium 144+, Node.js v24
- **Bundle:** 80–150 MB; **Idle RAM:** 150–300 MB; **Startup:** 1–2s
- Powers VS Code, Slack, Discord, Figma, 1Password — huge ecosystem
- **Pros:** familiar web tech, massive npm ecosystem, well-documented
- **Cons:** bloated binary, high memory use, not native-looking, process model complexity

### Tauri v2 (Released October 2, 2024)
- Rust backend + **system WebView** (WKWebView on macOS, WebView2 on Windows 10 1803+/Windows 11)
- Security audited by Radically Open Security
- **Bundle:** as small as 1 MB, typically 2.5–10 MB; **Idle RAM:** ~30–40 MB; **Startup:** <0.4 s
- v2 adds **iOS + Android** mobile targets (one codebase for all platforms)
- Granular capability/permission system for IPC APIs
- Supports sidecar processes (run non-Rust services alongside the app)
- Adoption up ~35% YoY after v2.0 launch
- **Pros:** smallest bundles, fastest startup, Rust safety, mobile support
- **Cons:** WebView rendering differences across OS versions, Rust learning curve, IPC adds complexity

### Flutter Desktop
- Custom rendering engine (Skia / new **Impeller** engine)
- Impeller is the default for iOS/Android as of Flutter 3.29; macOS/Windows still need `--enable-impeller` flag
- Flutter 3.29–3.35: 30–50% reduction in jank frames
- **Bundle:** 10–30 MB; renders its own widgets (not OS-native)
- Google-backed, active development
- **Pros:** consistent cross-platform UI, strong mobile story, good tooling
- **Cons:** Dart language adoption is limited, no native widgets (accessibility implications), custom look/feel

### Qt 6
- **C++** primary; Python via **PyQt6** (GPL) or **PySide6** (LGPL — recommended for proprietary apps)
- Qt Widgets: traditional native-looking UI; **QML/Qt Quick**: modern declarative/animation-focused
- CMake required as build system in Qt6
- **Licensing:** PySide6 is LGPL (free for proprietary), PyQt6 requires commercial license; Qt Commercial adds Qt Design Studio, analytics, support
- **Pros:** truly native widgets, excellent performance, cross-platform for 30+ years, extensive docs
- **Cons:** learning curve, QML adds another language, commercial license complexity

### .NET MAUI vs Avalonia UI
**MAUI**
- Evolves from Xamarin.Forms; uses **Mac Catalyst** on macOS (iOS-for-Mac wrapper, NOT full native macOS SDK)
- Mac Catalyst limits access to native macOS APIs
- Windows target uses WinUI 3 (native)
- Good mobile support (iOS + Android)
- First-party Visual Studio tooling
- **No Linux support**

**Avalonia UI**
- Custom rendering via **Skia** — pixel-perfect UI across all platforms
- Up to 6× faster than MAUI in some benchmarks
- Strong migration path from WPF
- **First-class Linux support** (unlike MAUI)
- Can build macOS DMGs from Windows CI
- No official mobile support (experimental only)

### wxWidgets / wxPython
- Uses **truly native OS widgets** — the most native-looking option
- Actively maintained (wxPython Phoenix)
- License: wxWindows (LGPL-compatible, allows proprietary use)
- **Cons:** dated development experience, platform-specific quirks, less popular in 2025+ (most Python devs prefer PySide6)

### JavaFX / OpenJFX
- JVM-based; custom rendering (not native widgets)
- Large Java ecosystem; GraalVM native image can reduce startup time
- Not widely chosen for new desktop projects in 2026
- **License:** GPL with Classpath Exception (OpenJFX); commercial options via Gluon

### Wails (Go + WebView)
- Go backend + system WebView (WebView2 on Windows, WKWebView on macOS)
- **v2:** stable, production-ready; **v3:** alpha as of 2026 (multi-window support, procedural API)
- Bundle: 5–15 MB — much smaller than Electron
- **Best for:** Go developers who want a web-based UI layer

### Neutralinojs
- Extremely lightweight system-WebView framework (JS/TS)
- Bundle: 1–5 MB
- Less mature ecosystem than Tauri; fewer plugins/integrations
- Good for tiny utilities where bundle size is the priority

---

## Key Decision Factors

| Criteria | Best Options |
|---|---|
| Smallest bundle | Neutralinojs, Tauri |
| Best performance / memory | Qt, wxWidgets |
| Truly native look & feel | Qt Widgets, wxWidgets, .NET MAUI (Windows) |
| Web dev background | Tauri (modern), Electron (mature) |
| C# / .NET background | Avalonia UI, .NET MAUI |
| Go background | Wails |
| Python background | PySide6 (Qt), wxPython |
| Mobile + Desktop from one codebase | Tauri v2, Flutter |
| Linux + macOS + Windows | Avalonia, Qt, Tauri, Flutter |
| Open source, no licensing complexity | Tauri, Flutter, Avalonia, Wails |

---

## Recommendations

### "I'm a web developer — what should I use?"
**Tauri v2** is the modern answer. It combines web frontend tech (React/Vue/Svelte) with a lean Rust backend, provides tiny binaries and fast startup, and now supports mobile too. **Electron** remains valid if you need maximum ecosystem maturity and don't mind the size/memory costs.

### "I need the most native-looking app"
**Qt** (with Qt Widgets, PySide6 for Python or C++ directly) or **wxWidgets**. These use actual OS controls, not simulated widgets.

### "I'm building with C# / .NET"
**Avalonia UI** for consistency across platforms (including Linux), performance, and a WPF-like experience. **MAUI** if iOS/Android mobile is also a target and macOS Mac Catalyst limitations are acceptable.

### "I'm a Go developer"
**Wails** — it was built for this use case.

### "I need mobile + desktop from one codebase"
**Tauri v2** (web + Rust) or **Flutter** (Dart). Both are viable; Flutter has more mature mobile patterns while Tauri has better desktop performance.

### "I need the absolute smallest binary"
**Neutralinojs** (1–5 MB) or **Tauri** (1–10 MB).

---

## Bottom Line

- **Tauri v2** is the most exciting option in 2026: small, fast, secure, cross-platform including mobile.
- **Electron** remains dominant in production due to sheer ecosystem size, but it's aging.
- **Qt** is the gold standard for truly native, high-performance apps, but has licensing complexity.
- **Flutter** is compelling if you're already in the Dart/Flutter ecosystem (especially mobile-first teams expanding to desktop).
- **Avalonia UI** is the best C# option if Linux support or raw performance matters.

---

## References

Research conducted via web searches on 2026-02-27. Key sources:
- Official framework docs and changelogs (Tauri, Flutter, Qt, Electron, Wails, MAUI, Avalonia)
- GitHub repositories and release notes
- Community comparisons (Reddit r/rust, r/dotnet, r/FlutterDev, Hacker News threads)
- Tauri v2 security audit report (Radically Open Security, 2024)
