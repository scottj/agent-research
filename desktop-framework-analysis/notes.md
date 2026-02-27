# Desktop Framework Analysis Notes

**Date:** 2026-02-27
**Task:** Analyze options for cross-platform desktop applications (macOS + Windows)

## Investigation Plan

1. Research major frameworks
2. Evaluate each on key criteria: language, performance, native feel, ecosystem, bundle size, community
3. Build comparison matrix
4. Document findings in README.md

## Frameworks to Evaluate

- Electron (JavaScript/Node.js)
- Tauri (Rust + WebView)
- Flutter (Dart)
- Qt (C++/Python/other bindings)
- .NET MAUI (C#)
- wxWidgets (C++)
- JavaFX / OpenJFX (Java)
- Wails (Go + WebView)
- NW.js (JavaScript/Node.js)
- Neutralinojs (C++ + WebView)

## Research Notes

### Electron
- Uses Chromium + Node.js
- Bundles entire browser engine
- Bundle sizes typically 100-200MB+
- Very large ecosystem (VS Code, Slack, Discord, etc.)
- Pros: Familiar web tech, massive ecosystem, cross-platform
- Cons: High memory usage (multiple processes), large binary, not truly native look
- Node.js runtime included

### Tauri
- Rust backend + system WebView (WKWebView on macOS, WebView2 on Windows)
- Frontend: Any JS framework (React, Vue, Svelte, etc.)
- Much smaller bundles vs Electron (1-10MB typical)
- Better performance and memory usage than Electron
- Tauri v2 released late 2024 (mobile support added for iOS/Android)
- Cons: System WebView inconsistencies across platforms, Rust learning curve
- IPC bridge required for frontend-backend communication
- Growing rapidly in popularity

### Flutter
- Dart language
- Custom rendering engine (Skia/Impeller) - draws its own UI
- NOT using native widgets, has its own widget system
- Good cross-platform consistency
- Desktop support went stable around 2022
- Bundle sizes: 10-30MB typical
- Google-backed
- Cons: Dart is less common, doesn't use native widgets (accessibility implications), custom look/feel

### Qt
- C++ primary (with Python via PyQt/PySide bindings, also .NET, Go, etc.)
- Uses native widgets or custom rendering (QML)
- Very mature and battle-tested (commercial + LGPL license)
- High performance
- Commercial license required for some features
- Bundle size: Varies, can be large if bundling Qt libraries
- LGPL allows free use for applications
- QML: declarative language for UI (can feel non-native)

### .NET MAUI (Multi-platform App UI)
- C# language, .NET ecosystem
- Uses native controls on each platform
- Evolved from Xamarin.Forms
- Microsoft-backed
- Desktop support for Windows (WinUI 3) and macOS (Mac Catalyst)
- Bundle sizes: Moderate (requires .NET runtime)
- Good tooling in Visual Studio
- Cons: macOS support sometimes feels second-class to Windows, Mac Catalyst has limitations

### wxWidgets
- C++ library
- Uses native platform widgets - looks truly native
- Very mature (since 1992)
- Bindings: wxPython is popular
- Cons: Dated development experience, less modern tooling
- Bundle size: Small to medium

### JavaFX / OpenJFX
- Java
- Custom rendering (not native widgets)
- JVM overhead
- Not widely used for new projects
- GraalVM native image can help with startup time
- Large ecosystem from Java

### Wails
- Go backend + system WebView
- Similar concept to Tauri but for Go developers
- Much smaller than Electron
- v2 is stable, v3 in development
- Good for Go developers who want web UI

### NW.js
- Similar to Electron (Chromium + Node.js)
- Older, less active than Electron
- Less popular now

### Neutralinojs
- Lightweight alternative to Electron
- Uses system WebView
- Very small bundle
- Less mature ecosystem than Tauri

## Key Decision Criteria

1. **Bundle Size**: Electron is worst; Tauri/Neutralinojs are best using system WebView
2. **Performance/Memory**: Native apps > WebView apps > Electron
3. **Native Look & Feel**: Qt/wxWidgets/MAUI best; Flutter/Electron have custom UI
4. **Language Preference**: Major factor - JS/TS (Electron, Tauri frontend), Rust (Tauri), Go (Wails), C++ (Qt, wx), C# (MAUI), Dart (Flutter), Java (JavaFX)
5. **Ecosystem/Libraries**: Node.js ecosystem largest, then Java/C#
6. **Development Speed**: Web-based (Electron, Tauri) fastest for web devs; others require more learning
7. **Community/Maintenance**: Electron most mature desktop-web hybrid; Tauri growing fast
8. **Licensing**: Qt commercial considerations, others mostly open source
9. **Mobile expansion**: Tauri v2, Flutter have mobile support
10. **Accessibility**: Native widget frameworks better for a11y

## Research Findings (from web search, 2026-02-27)

### Electron (current: v39-41 as of early 2026)
- Ships 6 major versions/year, tracking every other Chromium release
- Chromium 144+ in v41 betas, Node.js v24 in latest versions
- Bundle: 80-150MB, RAM idle: 150-300MB
- A basic to-do list: 250MB RAM, 1.5s startup
- Large ecosystem: VS Code, Slack, Discord, Figma, 1Password
- Memory leaks progressively fixed (Linux GTK icon leak fixed in 2025)
- macOS Catalina support dropped in v33+

### Tauri v2 (released October 2, 2024)
- Stable release, independently audited by Radically Open Security
- Extended to iOS + Android in v2 (desktop + mobile from one codebase)
- WebView2 on Windows: pre-installed on Win 10 1803+, Win 11
- App sizes: as small as 1MB; typical 2.5-10MB
- RAM: ~30-40MB idle
- Startup: <0.4s vs Electron's 1-2s
- Security: granular capabilities system for API permissions
- Sidecar support: can run non-Rust processes as sidecars
- Adoption up 35% YoY after v2.0 release

### Flutter Desktop
- Impeller (new rendering engine): DEFAULT on iOS and Android as of 3.29
- macOS/Windows: Impeller in preview, must be enabled via --enable-impeller flag
- Desktop support mature but Impeller not yet default
- Flutter 3.29-3.35: 30-50% reduction in jank frames
- Bundle size: medium (custom Skia/Impeller rendering, no system webview)
- Dart language - not widely adopted compared to JS/TS or C#

### Qt 6 (PyQt6 vs PySide6)
- PyQt6: GPL license (requires commercial license for proprietary apps)
- PySide6: LGPL license (free for proprietary apps, maintained by Qt Company)
- Qt Commercial: adds Qt Design Studio, Qt Insight analytics, premium support
- CMake required as build system in Qt6
- QML (Qt Quick): for modern fluid UIs, better for declarative/animation-heavy
- Qt Widgets: for traditional desktop UIs, better native look

### .NET MAUI vs Avalonia
- MAUI: Uses Mac Catalyst on macOS (wrapper, NOT native macOS SDK)
  - Mac Catalyst is iOS-for-Mac, limited access to native macOS APIs
  - Better mobile support (iOS + Android)
  - First-party Visual Studio tooling
- Avalonia: Custom rendering (Skia), pixel-perfect across platforms
  - Up to 6x faster than MAUI on some benchmarks
  - Strong WPF migration path
  - Linux first-class support (MAUI has none)
  - No official mobile (experimental)
  - New packaging: can build macOS DMG from Windows

### Wails (Go + WebView)
- v2: stable, production use
- v3: ALPHA as of 2026, reasonably stable API, some in production
- v3 adds multi-window support, procedural approach
- Uses WebView2 on Windows (like Tauri)
- Good for Go developers, smaller than Electron
- Build system improvements ongoing

### wxWidgets / wxPython
- Still actively maintained (wxPython Phoenix)
- Unique: truly native widgets on each platform (not custom rendering)
- License: wxWindows (LGPL-like), allows proprietary use
- Drawbacks: dated development experience, platform-specific quirks
- For Python: most developers prefer PyQt6/PySide6 in 2025+

## Observations / Conclusions

- **For web developers**: Tauri is the modern choice over Electron (smaller, faster, Rust security)
- **For native feel requirement**: Qt (C++) or .NET MAUI (C#)
- **For Flutter devs**: Flutter Desktop is viable but custom widgets
- **Electron is still dominant** in production due to its maturity and ecosystem
- **Tauri** is the most exciting newer option with best balance of size and web tech
- **Go developers**: Wails is the natural choice

## Comparison Table Draft

| Framework | Language | Bundle Size | Native UI | Performance | License |
|-----------|----------|-------------|-----------|-------------|---------|
| Electron  | JS/TS    | 100-200MB+  | No        | Poor        | MIT     |
| Tauri     | Rust+Web | 1-10MB      | No (WebView)| Good     | MIT/Apache|
| Flutter   | Dart     | 10-30MB     | No (Custom)| Good      | BSD     |
| Qt        | C++/Python | Varies    | Yes       | Excellent   | LGPL/Commercial |
| .NET MAUI | C#       | 30-80MB     | Yes       | Good        | MIT     |
| wxWidgets | C++/Python | 5-20MB   | Yes       | Excellent   | wxWindows |
| JavaFX    | Java     | 40-80MB     | No (Custom)| Moderate  | GPL/Commercial |
| Wails     | Go+Web   | 5-15MB      | No (WebView)| Good    | MIT     |
| Neutralinojs | JS/TS | 1-5MB     | No (WebView)| Good    | MIT     |
