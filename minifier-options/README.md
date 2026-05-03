# Minification Tools Compared

<!-- AI-GENERATED-NOTE -->
> [!NOTE]
> This is an AI-generated research report. All text and code in this report was created by an LLM (Large Language Model). For more information on how these reports are created, see the [main research repository](https://github.com/scottj/agent-research).
<!-- /AI-GENERATED-NOTE -->

## Bottom line

If you like `html-minifier-terser` because one tool can handle HTML plus inline JS and CSS, the most relevant alternatives are:

- `html-minifier-next`: the closest replacement in spirit and API shape.
- `@minify-html/node`: the strongest modern rewrite if speed and malformed/template-heavy input matter.
- `htmlnano`: the most modular option if you want more explicit control and good build-pipeline integration.

If your current `html-minifier-terser` setup is stable and you mostly care about not changing output behavior, staying put is still reasonable. If you want something newer without changing mental models much, `html-minifier-next` is the first tool I would try.

## Comparison

| Tool | HTML + inline JS/CSS | Best fit | Main strengths | Main tradeoffs |
| --- | --- | --- | --- | --- |
| `html-minifier-terser` | Yes | Keep existing behavior with minimal churn | Mature option surface, strong template-ignore hooks, familiar ecosystem | Tree-based serializer cannot preserve invalid/partial HTML; CSS still goes through `clean-css`; current package/release activity looks slower than the newer options |
| `html-minifier-next` | Yes | Closest drop-in successor to `html-minifier-terser` | Same general model, backward-compatibility goal, Lightning CSS for CSS, newer CLI/preset/dry-run features, ReDoS protections | Same tree-based invalid/partial-HTML limitation as the original family |
| `@minify-html/node` | Yes | Max performance and better tolerance for real-world or template-heavy input | Rust implementation, handles invalid HTML, preserves common template syntax, modern CSS/JS backends | Not a drop-in API match; Node package is a native binding; configuration style is different |
| `htmlnano` | Yes, but JS/CSS minification is modular and opt-in | PostHTML/bundler workflows, selective transforms, safer defaults | Modular architecture, safe/amp/max presets, detailed per-module control | Not a drop-in replacement; inline JS/CSS support requires extra packages; less compelling if you want one self-contained dependency |

## Tool notes

### `html-minifier-terser`

Why keep it:

- It still has one of the nicest “all in one” ergonomics for HTML, inline CSS, and inline JS.
- It supports ignore fragments and custom event/script handling, which is useful for templating and mixed-content builds.
- If you already have a tuned config, it is hard to beat on migration cost.

Why move off it:

- Its own docs say it cannot preserve invalid or partial HTML because it parses into a tree and reserializes.
- It still routes CSS minification through `clean-css`, while newer alternatives have moved to newer CSS engines.
- Based on the official pages I checked on May 3, 2026, it looks more stable/mature than fast-moving.

### `html-minifier-next`

Why it stands out:

- It is explicitly built as a successor to the `html-minifier` / `html-minifier-terser` line.
- It keeps the familiar high-configurability model, supports inline CSS and JS minification, and aims for backward compatibility.
- It upgrades CSS minification to Lightning CSS and adds operational features that the older toolchain does not emphasize as much: presets, dry runs, directory processing, verbose stats, and documented ReDoS protections.

What to watch:

- Architecturally it is still in the same family, so malformed or partial HTML remains a limitation.
- It is the best choice if you want “like `html-minifier-terser`, but more current,” not if you want a fundamentally different parser/minifier.

### `@minify-html/node`

Why it stands out:

- It is the strongest alternative if you care about speed and resilience.
- Its docs explicitly say it handles invalid HTML and common template syntaxes like `{% raw %}{{ }}{% endraw %}`, `{% raw %}{% %}{% endraw %}`, `{# #}`, and `<% %>`.
- It uses modern CSS/JS minifiers (`lightningcss` and, in the current repo/docs I checked, `oxc` for JS).

What to watch:

- The Node package is a Neon/native binding, so this is not the same deployment profile as a pure JS package.
- The API and config shape are different enough that this is more of a migration than a swap.
- It feels more like “new engine with different tradeoffs” than “drop-in replacement.”

### `htmlnano`

Why it stands out:

- It is the most tunable option if you want HTML minification as part of a larger HTML/PostHTML pipeline.
- The module model is clean: start with a preset, then turn individual transforms on/off.
- It has dedicated modules for inline CSS, inline JS, URL rewriting, and minifying HTML inside template containers.

What to watch:

- Inline CSS/JS minification is not as turnkey as `html-minifier-terser`; you install extra packages for those modules.
- It is better thought of as “HTML optimization pipeline tooling” than “one package that behaves like `html-minifier-terser`.”

## What I would choose

### If you want the smallest migration from `html-minifier-terser`

Choose `html-minifier-next`.

Reason:

- It preserves the same general model and option vocabulary.
- It looks like the clearest path if you want modernized behavior without rethinking your build.

### If you want a more modern engine

Choose `@minify-html/node`.

Reason:

- It is the most compelling option when speed, malformed HTML tolerance, and template-heavy source matter more than drop-in compatibility.

### If you want maximum control in a build pipeline

Choose `htmlnano`.

Reason:

- It gives you the cleanest knob-by-knob control and fits naturally into PostHTML/bundler flows.

### If you are happy today and just want a sanity check

Staying on `html-minifier-terser` is defensible.

Reason:

- It still does the rare thing you care about well: HTML plus inline JS and CSS from one tool.
- The strongest argument to switch is not “it is bad,” but “other tools may fit your future constraints better.”

## Secondary options

These exist, but I would not put them on the short list unless you have a specific reason:

- `html-minifier`: legacy ancestor; important historically, but mostly relevant for compatibility.
- `minimize`: old HTML minifier; explicitly not designed for inline PHP/raw templates.
- `html-minify`: old wrapper around older minifiers.
- `minify`: useful CLI/orchestrator across file types, but its HTML path still leans on older HTML-minifier tooling rather than a distinct HTML engine.
- `@node-minify/html-minifier`: wrapper/plugin around HTML minifier, not a new HTML minifier design.

## How to read benchmark claims

Several of these projects publish benchmark tables. I would treat those as directional, not decisive:

- `htmlnano`’s published tables generally show better output-size reduction than `html-minifier-terser`.
- `html-minifier-next` also publishes comparisons that show strong compression results.
- `minify-html` emphasizes speed while claiming competitive or better compression.

Those are useful signals, but each project authors its own corpus and settings. For a real decision, I would run one or two of these against your own HTML templates and compare:

- output size
- runtime
- whether any template fragments or whitespace-sensitive cases break
- install/runtime friction in your environment

## Recommendation

For someone who already likes `html-minifier-terser`, I would evaluate alternatives in this order:

1. `html-minifier-next` if you want the nearest successor.
2. `@minify-html/node` if you want the strongest modern alternative.
3. `htmlnano` if you want a more modular pipeline-oriented approach.

If you want, the next step can be a concrete migration matrix: translate a typical `html-minifier-terser` config into equivalent configs for `html-minifier-next`, `@minify-html/node`, and `htmlnano`.

## Sources

- `html-minifier-terser` GitHub: <https://github.com/terser/html-minifier-terser>
- `html-minifier-terser` releases: <https://github.com/terser/html-minifier-terser/releases>
- `minify-html` GitHub: <https://github.com/wilsonzlin/minify-html>
- `@minify-html/node` npm package page: <https://www.npmjs.com/package/@minify-html/node>
- `htmlnano` docs: <https://htmlnano.netlify.app/>
- `htmlnano` modules docs: <https://htmlnano.netlify.app/modules>
- `htmlnano` usage docs: <https://htmlnano.netlify.app/usage>
- `htmlnano` presets docs: <https://htmlnano.netlify.app/presets>
- `htmlnano` npm package page: <https://www.npmjs.com/package/htmlnano>
- `html-minifier-next` GitHub: <https://github.com/j9t/html-minifier-next>
- `html-minifier-next` demo/docs: <https://j9t.github.io/html-minifier-next/>
- `minimize` npm package page: <https://www.npmjs.com/package/minimize>
- `minify` npm package page: <https://www.npmjs.com/package/minify>
- `@node-minify/html-minifier` npm package page: <https://www.npmjs.com/package/@node-minify/html-minifier>
