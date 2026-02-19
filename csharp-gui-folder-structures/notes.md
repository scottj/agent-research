# Research Notes: C# GUI App Project Structures

## Date: 2026-02-17

## Research Summary

### Sources consulted:
- learn.microsoft.com (CommunityToolkit MVVM docs, WinUI tutorials, MAUI architecture)
- albertakhmetov.com - WinUI application project structure 2025 post
- blog.rsuter.com - MVVM best practices for XAML .NET
- developersvoice.com - .NET MAUI for architects 2025
- antondevtips.com - Vertical slice architecture best ways to structure
- milanjovanovic.tech - Clean architecture folder structure
- community.devexpress.com - Modern desktop apps architectures (2024)
- GitHub repos: files-community/Files, AvaloniaUI/Avalonia.MusicStore, reactiveui/Camelotia, CommunityToolkit/MVVM-Samples
- Prism library docs (prismlibrary.github.io)
- Various Medium/blog articles

### Key Findings:

#### Classic MVVM
- Three core folders: Models/, Views/, ViewModels/
- Often augmented with Services/, Helpers/, Controls/
- Rico Suter (blog.rsuter.com) recommends also adding Localization/ and Controls/ (reusable controls without VMs)
- Naming: Views end with *Window, *Dialog, *Page, *View; VMs end with *ViewModel

#### Multi-project split
- Recommended by multiple sources: split into AppName.Core (VMs, models, service interfaces) + AppName (UI, platform code)
- albertakhmetov.com 2025 article specifically recommends this for WinUI
- CommunityToolkit MVVM sample (Reddit browser) uses separate .Core project for VMs/services, platform project for UI
- Files app (files-community/Files) uses many projects: Files.App, Files.Core.Storage, Files.App.Storage, Files.Shared, Files.App.Controls, etc.

#### Clean Architecture / Onion
- 4 layers: Domain, Application, Infrastructure, Presentation (MAUI/WPF project)
- matt-goldman/MauiCleanTodos is a reference implementation
- XivotecGmbH/CleanArchitecture.Maui is a NuGet template
- Domain has no dependencies; infrastructure implements domain interfaces
- DI wired in MauiProgram.cs or App.xaml.cs

#### Vertical Slice / Feature Folders
- Organize by feature (CreateShipment/, UpdateStatus/) rather than by layer
- antondevtips.com identifies 4 sub-approaches (per-feature folder, single file nested, hybrid, pragmatic)
- Most VSA examples are ASP.NET Core - adaptation to desktop GUI is less documented
- spin.atomicobject.com article "Creating a Feature-Oriented C# Structure" applies to general C#
- For desktop: put View.xaml + ViewModel.cs + Model.cs together in Features/FeatureName/

#### CommunityToolkit.Mvvm
- No enforced project structure - "flexible usage"
- Official sample uses: MvvmSample.Core/ (ViewModels, Services, interfaces) + platform apps (UWP, WinForms, WPF, Xamarin)
- DI via Microsoft.Extensions.DependencyInjection
- ViewModels inherit ObservableObject or ObservableRecipient
- [ObservableProperty] source generators reduce boilerplate

#### ReactiveUI
- Default Avalonia template: Views/, ViewModels/ folders + ReactiveUI.Avalonia NuGet
- Camelotia (cross-platform sample): src/ with separate projects per platform (Camelotia.Presentation.Avalonia, .Wpf, .Uwp)
- Shared core in a .NET Standard project
- Reactive approach tends toward more projects, less flat folder structure

#### Prism
- Module-centric: each module DLL has Views/ and ViewModels/ inside it
- Shell hosts regions (MainRegion, etc.); modules register views into regions
- Module discovery via MEF DirectoryCatalog or code/XAML registration
- Enterprise-focused; more verbose but highly decoupled

#### Files App (files-community/Files) - WinUI 3 real-world
- src/ contains: Files.App, Files.App.Controls, Files.App.Storage, Files.Core.Storage, Files.App.Server, Files.App.BackgroundTasks, Files.App.Launcher, Files.App.CsWin32, Files.App.OpenDialog, Files.App.SaveDialog, Files.Shared, Files.Core.SourceGenerator
- Multi-project solution with clear separation of concerns
- No feature-slice approach - uses layer/concern separation across projects

#### Avalonia MusicStore sample
- Simple single project: Avalonia.MusicStore/ + Avalonia.MusicStore.Backend/
- CommunityToolkit.Mvvm, Mvvm.Messaging, ObservableProperty
- Archived Feb 2024

### Community Sentiment (inferred from multiple sources):
- Classic 3-folder MVVM is widely understood and still common for small/medium apps
- Multi-project Core + UI split is considered "modern best practice" for testability
- Feature slices are trending in web/API world; adoption in desktop is slower but growing
- Prism is seen as "heavy enterprise" - less trendy
- ReactiveUI is popular in Avalonia community; has steeper learning curve
- CommunityToolkit.Mvvm is considered the "modern, pragmatic" choice for most devs
- Clean Architecture is respected but sometimes criticized as over-engineering for simple desktop apps
