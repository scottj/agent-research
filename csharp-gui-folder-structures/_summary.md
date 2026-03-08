C# GUI application development today is defined by a mix of legacy MVVM patterns, modular architectures, and modern, feature-centric folder structures across frameworks like WPF, WinUI 3, .NET MAUI, and Avalonia UI. While classic layer-based MVVM is still widely used for its familiarity, contemporary projects increasingly favor feature folders, vertical slice architecture, or clean architecture for improved scalability, testability, and developer onboarding. Multi-project splits (core logic + UI) are now recommended by Microsoft and embraced in flagship apps like [Files](https://github.com/files-community/Files), while community favorites like [Avalonia](https://github.com/AvaloniaUI/Avalonia) are pioneering cross-platform design patterns. Generally, feature-focused organization and clean separation of concerns are seen as best practices, and pragmatic teams start simple, evolving their structure as the app grows.

**Key Findings:**
- Feature folders and vertical slices are gaining popularity for their clarity, cohesion, and scalability.
- Multi-project (Core + UI) architecture is the mainstream recommendation for cross-platform and testable apps.
- Prism module approach remains relevant for plugin-heavy enterprise applications but is rarely chosen for greenfield projects.
- Layer-centric MVVM, while still present, is considered dated for new development.
- Active community frameworks and tooling impose little structural opinion, placing architectural responsibility on developers.
