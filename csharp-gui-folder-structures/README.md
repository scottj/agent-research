# C# GUI App Folder Structures: A Field Guide

<!-- AI-GENERATED-NOTE -->
> [!NOTE]
> This is an AI-generated research report. All text and code in this report was created by an LLM (Large Language Model). For more information on how these reports are created, see the [main research repository](https://github.com/scottj/agent-research).
<!-- /AI-GENERATED-NOTE -->

> **Focus:** What's actually used, what's gaining steam, and what's considered a relic.
> **Frameworks covered:** WPF · WinUI 3 · .NET MAUI · Avalonia UI
> **Date:** February 2026

---

## The Landscape

C# GUI development has fractured into a rich ecosystem. WPF still powers enormous amounts of enterprise Windows software. WinUI 3 is Microsoft's new flagship (slow burn adoption). MAUI is the cross-platform mobile/desktop play. And **Avalonia** has quietly become the community darling — the most-starred .NET UI framework on GitHub, used by companies like JetBrains, Unity, and GitHub itself.

With that diversity comes a wide range of folder structure philosophies, from buttoned-up enterprise blueprints to opinionated, feature-first layouts borrowed from the JavaScript world. Here's an opinionated breakdown.

---

## 1. Classic Layer-Based MVVM — The Old Guard

**Hip-o-meter: ★☆☆☆☆**

The default Microsoft template and every "Getting Started with WPF" tutorial from 2010–2020 taught this structure. Organize by *technical role*, not by *purpose*. Rico Suter's well-cited blog post recommends augmenting it with `Localization/` and `Controls/` (for reusable controls without view models), but the core shape is unchanged.

```
MyApp/
├── Models/
│   ├── Customer.cs
│   └── Order.cs
├── ViewModels/
│   ├── CustomerViewModel.cs
│   └── OrderViewModel.cs
├── Views/
│   ├── CustomerView.xaml       ← ends in *View, *Window, *Dialog, or *Page
│   └── OrderView.xaml
├── Services/
│   └── CustomerService.cs
├── Controls/                   ← reusable XAML controls (no VM)
├── Helpers/
│   └── RelayCommand.cs
└── App.xaml
```

**Pros**
- Universal familiarity — zero onboarding friction, copious tutorials
- Enforces separation of concerns at the folder level
- Works fine for small apps with few features

**Cons**
- Doesn't scale: adding a feature means touching 3+ folders simultaneously
- Folder tree tells you *how* the code is organized, not *what the app does*
- Feels immediately dated in code reviews — "oh, it's classic MVVM"
- No natural home for cross-cutting concerns (commands, converters, behaviors, validators)

**Who uses it:** Legacy WPF enterprise apps, beginners following old tutorials, teams with established "WPF style guides" from 2012.

---

## 2. Multi-Project Core + UI Split — The Sensible Upgrade

**Hip-o-meter: ★★★☆☆**

A widely recommended step up from flat classic MVVM: separate the app into a platform-agnostic `.Core` project (ViewModels, models, service interfaces) and a platform project (XAML, views, platform-specific bindings). The CommunityToolkit.Mvvm official sample (a Reddit browser) uses exactly this split. The Files app (WinUI 3, ~35k stars) takes it further into many targeted projects.

```
MyApp.sln
├── MyApp.Core/                 ← .NET Standard / net8.0 lib
│   ├── ViewModels/
│   ├── Models/
│   └── Services/
│       └── ICustomerService.cs
├── MyApp/                      ← WPF / WinUI / Avalonia / MAUI app
│   ├── Views/
│   ├── Services/               ← concrete service implementations
│   └── App.xaml
└── MyApp.Tests/
```

**Files app goes further:**
```
src/
├── Files.App/
├── Files.App.Controls/
├── Files.App.Storage/
├── Files.Core.Storage/
├── Files.Shared/
├── Files.App.Server/
└── Files.Core.SourceGenerator/
```

**Pros**
- Testability: `.Core` has no UI dependency, easy to unit test ViewModels
- Platform portability: swap the UI project to target a different framework
- Clean compile-time boundary between logic and UI
- Matches the pattern used by popular real-world WinUI/Avalonia apps

**Cons**
- Adds solution/project overhead for small apps
- Tempts you to make `.Core` into a dumping ground
- Doesn't address feature organization within each project

**Who uses it:** Recommended by Microsoft MAUI architecture docs, the CommunityToolkit.Mvvm team, albertakhmetov.com's 2025 WinUI guide. Considered "modern best practice" for testability.

---

## 3. Prism Module Architecture — The Formal Suit

**Hip-o-meter: ★☆☆☆☆**

Prism (Microsoft Patterns & Practices, now community-maintained) turns each major feature into its own compiled DLL, dynamically loaded into a Shell at runtime. The Shell defines named Regions; modules register Views into those Regions. It's powerful, mature, and wildly over-engineered for anything under ~50 screens.

```
MyApp.sln
├── MyApp.Shell/                ← host app: regions, navigation, bootstrapper
├── MyApp.Infrastructure/       ← shared interfaces, base classes, events
├── Modules/
│   ├── MyApp.Customers/
│   │   ├── Views/
│   │   │   └── CustomerListView.xaml
│   │   ├── ViewModels/
│   │   │   └── CustomerListViewModel.cs
│   │   └── CustomerModule.cs   ← IModule registration
│   └── MyApp.Orders/
│       ├── Views/
│       ├── ViewModels/
│       └── OrderModule.cs
└── MyApp.Tests/
```

**Pros**
- True runtime modularity — modules loaded on demand (or from plugin directories)
- Strong team isolation — module owners never touch each other's code
- Mature DI, event aggregator, and navigation infrastructure
- Ideal for plugin-based or dynamically extensible applications

**Cons**
- Massive boilerplate for the first 20% of features
- 10–50 module solutions visibly slow Visual Studio
- Steep learning curve: Regions, EventAggregator, ModuleCatalog, IContainerRegistry
- Community perception: "Prism? What year is it?"
- Debugging Prism magic can feel like archaeology

**Who uses it:** Large industrial WPF apps, defense/government contractors, LOB software shops that adopted Prism in the early 2010s. Not recommended for new greenfield projects by most community voices.

---

## 4. Clean Architecture (Onion) — The Thoughtful Engineer

**Hip-o-meter: ★★★☆☆**

Four concentric layers, each a separate VS project. The inner rings (Domain, Application) have zero outward dependencies. Infrastructure and UI depend inward. Popularized by Robert Martin's book and Jason Taylor's `CleanArchitecture` template (now for ASP.NET Core, but widely adapted for desktop).

```
MyApp.sln
├── src/
│   ├── MyApp.Domain/           ← entities, value objects, domain events
│   ├── MyApp.Application/      ← use cases, CQRS commands/queries, interfaces
│   ├── MyApp.Infrastructure/   ← file I/O, databases, external APIs
│   └── MyApp.UI/               ← WPF/Avalonia/MAUI project, Views, ViewModels
└── tests/
    ├── MyApp.Domain.Tests/
    ├── MyApp.Application.Tests/
    └── MyApp.Integration.Tests/
```

**Avalonia / ReactiveUI lean variant** (from official ReactiveUI docs):
```
MyApp/                          ← netstandard2.0: ViewModels, logic, reactive chains
MyApp.Avalonia/                 ← platform Views, bootstrapping
MyApp.Tests/
```

**Pros**
- Genuinely testable — Domain and Application layers have no UI coupling
- Easy to swap UI frameworks (tried Avalonia, want MAUI? just swap the UI project)
- Forces dependency-direction discipline upfront
- MAUI architecture guidance from Microsoft explicitly recommends this

**Cons**
- Heavy ceremony for small apps ("clean architecture tax")
- Can produce thin projects with 3 classes each
- Interface-for-everything can feel academic
- Onboarding juniors requires explaining the dependency inversion rule repeatedly

**Who uses it:** Teams with .NET API backgrounds bringing web habits to desktop. Reference implementations: `matt-goldman/MauiCleanTodos`, `XivotecGmbH/CleanArchitecture.Maui`. Strong in the Avalonia/ReactiveUI community.

---

## 5. Feature Folders / Screaming Architecture — The Pragmatic Hipster

**Hip-o-meter: ★★★★☆**

Instead of organizing by technical layer, organize by *what the app does*. Each top-level folder is a feature. Uncle Bob coined "Screaming Architecture": glance at the folder tree and know what the system does, not how it's wired. Atomic Object wrote an early C#-specific take on this that is still widely cited.

```
MyApp/
├── Features/
│   ├── Customers/
│   │   ├── CustomerView.xaml
│   │   ├── CustomerViewModel.cs
│   │   ├── CustomerModel.cs
│   │   ├── CustomerService.cs
│   │   └── CustomerTests.cs    ← colocated tests: coverage gaps are obvious
│   ├── Orders/
│   │   ├── OrderView.xaml
│   │   ├── OrderViewModel.cs
│   │   └── OrderService.cs
│   └── Dashboard/
│       ├── DashboardView.xaml
│       └── DashboardViewModel.cs
├── Common/
│   ├── Behaviors/
│   ├── Converters/
│   └── Controls/
└── App.xaml
```

**Pros**
- Finding all code for a feature is trivial — it's in one folder
- New developers grasp the app's purpose from the folder tree instantly
- Scales gracefully: new features are new folders, not new layers
- Easy to delete a feature — no hunting across layer folders
- Mirrors patterns popular in modern JS/TS (Next.js app router, Angular standalone modules)
- Test colocation makes coverage gaps visible at a glance

**Cons**
- Shared code placement gets contentious fast (`IUserContext` — Feature or Common?)
- Namespace conventions need an early team decision (mirror folders vs. flat?)
- Test deployment: colocated tests ship in the prod assembly unless explicitly split
- Visual Studio scaffolding still generates layer-based structure — no tooling help
- Disorienting for devs who grew up with pure MVVM structure

**Who uses it:** Mid-size apps, developers coming from Angular/React, teams who've read Milan Jovanovic or Atomic Object posts. Growing fast in .NET community discourse.

---

## 6. Vertical Slice Architecture — The True Believer

**Hip-o-meter: ★★★★★**

The logical extreme of feature folders. Each *slice* is a fully self-contained unit: its own handler, DTO, validator, query, and view. Pioneered by Jimmy Bogard (MediatR author) for ASP.NET Core, now spreading to desktop. `nadirbad/VerticalSliceArchitecture` is a popular template (540+ stars).

```
MyApp/
├── Features/
│   ├── CreateCustomer/
│   │   ├── CreateCustomerCommand.cs
│   │   ├── CreateCustomerHandler.cs   ← MediatR IRequestHandler
│   │   ├── CreateCustomerView.xaml
│   │   ├── CreateCustomerViewModel.cs ← thin, just sends command via mediator
│   │   └── CreateCustomerValidator.cs
│   ├── ListCustomers/
│   │   ├── ListCustomersQuery.cs
│   │   ├── ListCustomersHandler.cs
│   │   ├── ListCustomersView.xaml
│   │   └── ListCustomersViewModel.cs
│   └── DeleteCustomer/
│       ├── DeleteCustomerCommand.cs
│       └── DeleteCustomerView.xaml
├── Common/
│   └── Infrastructure/
│       └── Behaviors/              ← MediatR pipeline: logging, validation, etc.
└── App.xaml
```

ViewModels are thin dispatchers; handlers own all feature logic.

**Pros**
- Maximum cohesion — a slice changes for one reason only
- Zero cross-feature coupling by default
- Adding a feature never touches existing code
- Folder = ticket = PR — clean mapping to work units
- Cross-cutting concerns (logging, auth, validation) live in pipeline behaviors, not scattered everywhere

**Cons**
- More files per feature — can feel noisy in small apps
- Shared concepts (`Customer` as a data model) can get duplicated across slices
- MediatR adds a dependency and adds indirection to the call stack
- Cross-feature navigation and shared state require deliberate design
- Less documented for GUI apps vs. APIs — community is still working it out

**Who uses it:** Developers who've used VSA on backend APIs and want the same hygiene on desktop. Particularly popular in Avalonia projects where the shared-library pattern encourages decoupled feature handling.

---

## 7. CommunityToolkit.Mvvm Flat Style — The Pragmatic Default

**Hip-o-meter: ★★★☆☆**

Microsoft's `CommunityToolkit.Mvvm` (formerly `Microsoft.Toolkit.Mvvm`) is intentionally structure-agnostic. Source-generated `[ObservableProperty]` and `[RelayCommand]` eliminate boilerplate. The official multi-platform sample (Reddit browser) uses a `.Core` + platform split, but the library doesn't enforce anything. In practice most teams start flat and evolve.

```
MyApp/
├── ViewModels/
│   ├── MainViewModel.cs        ← [ObservableProperty] / [RelayCommand]
│   └── CustomerViewModel.cs
├── Views/
│   ├── MainWindow.xaml
│   └── CustomerView.xaml
├── Models/
│   └── Customer.cs
├── Services/
│   └── ICustomerService.cs
└── App.xaml
```

**Pros**
- Microsoft-backed, actively maintained, signed NuGet package
- Roslyn source generators eliminate `OnPropertyChanged` boilerplate
- Platform-agnostic: WPF, WinUI 3, MAUI, Avalonia — all supported
- `ObservableRecipient` + `WeakReferenceMessenger` for decoupled messaging
- Great entry point; easy to grow into feature folders without rewriting

**Cons**
- No structural opinions — you still have to decide your architecture
- Default template leads back to Classic Layer-Based MVVM unless you're deliberate
- Source generators can confuse devs unfamiliar with Roslyn analyzers

**Who uses it:** Essentially every new WPF, WinUI 3, and MAUI project in 2024–2026. The baseline, not the destination.

---

## Comparison Matrix

| Structure | Coolness | Scalability | Testability | Ceremony | Learning Curve |
|---|---|---|---|---|---|
| Classic Layer MVVM | ★☆☆☆☆ | Poor | Moderate | Low | Minimal |
| Multi-Project Core+UI | ★★★☆☆ | Good | Good | Moderate | Low |
| Prism Modules | ★☆☆☆☆ | Excellent | Good | Very High | High |
| Clean Architecture | ★★★☆☆ | Good | Excellent | High | Moderate |
| Feature Folders | ★★★★☆ | Good | Good | Low | Low |
| Vertical Slices | ★★★★★ | Excellent | Excellent | Moderate | Moderate |
| CommunityToolkit flat | ★★★☆☆ | Moderate | Moderate | Low | Minimal |

---

## What the Cool Kids Are Actually Doing

- **Files app** (WinUI 3, ~35k GitHub stars): Multi-project with concern-based project separation (Controls, Storage, Shared, etc.). Not feature-sliced, but far beyond flat classic MVVM.
- **Avalonia community templates**: Push the shared-library + ReactiveUI pattern. Close to Clean Arch lite.
- **JetBrains Rider** (built on Avalonia): Component/feature grouping, not layer-based.
- **CommunityToolkit.Mvvm samples**: `.Core` + platform app split as the reference pattern.
- **r/dotnet & r/csharp consensus**: Feature folders increasingly preferred; Classic MVVM "fine but boring"; Prism considered legacy for new projects; Vertical Slices exciting but still maturing on the desktop side.

---

## Recommendation

| If you're building... | Reach for... |
|---|---|
| Small app / prototype | CommunityToolkit.Mvvm + Classic MVVM — get moving, reorganize later |
| Medium app, solo or small team | Feature Folders + CommunityToolkit.Mvvm — readable, scalable, no ceremony |
| Large / long-lived app, experienced team | Vertical Slices — max cohesion, clean feature boundaries |
| Large / long-lived app, mixed experience | Clean Architecture — enforced dependency rules help juniors |
| Giant enterprise LOB with runtime plugins | Prism — still the right tool, just don't let it be a new hire's first impression |
| Cross-platform (Avalonia / MAUI) | Multi-project Core + UI split as baseline, layer feature folders on top |

---

## Sources

- [Feature-Oriented C# Structure — Atomic Object](https://spin.atomicobject.com/feature-oriented-c-sharp-structure/)
- [Screaming Architecture — Milan Jovanovic](https://www.milanjovanovic.tech/blog/screaming-architecture)
- [Vertical Slice Architecture .NET Template — nadirbad](https://github.com/nadirbad/VerticalSliceArchitecture)
- [Vertical Slice Architecture Best Ways to Structure — Anton Dev Tips](https://antondevtips.com/blog/vertical-slice-architecture-the-best-ways-to-structure-your-project)
- [Avalonia + ReactiveUI + Clean Architecture — Medium](https://medium.com/c-sharp-programming/avalonia-and-reactiveui-mvvm-di-clean-architecture-67fe4777d463)
- [CommunityToolkit.Mvvm Introduction — Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/communitytoolkit/mvvm/)
- [MVVM Community Toolkit Features (MAUI) — Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/architecture/maui/mvvm-community-toolkit-features)
- [Prism Library for WPF — Prism Docs](https://prismlibrary.github.io/docs/wpf/legacy/Introduction.html)
- [Modular Application Development — Prism](https://docs.prismlibrary.com/docs/modularity/index.html)
- [Files App — files-community/Files](https://github.com/files-community/Files)
- [ReactiveUI for Avalonia](https://github.com/reactiveui/ReactiveUI.Avalonia)
- [WPF Best Practices 2024 — MESCIUS](https://medium.com/mesciusinc/wpf-development-best-practices-for-2024-9e5062c71350)
- [Clean Architecture Template — ardalis](https://github.com/ardalis/CleanArchitecture)
- [Clean Architecture Getting Started — Jason Taylor](https://jasontaylor.dev/clean-architecture-getting-started/)
- [MVVM Recommendations for XAML .NET — Rico Suter](https://blog.rsuter.com/recommendations-best-practices-implementing-mvvm-xaml-net-applications/)
