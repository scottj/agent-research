Evaluating HTML minification tools for workflows that rely on strong support for HTML plus inline JS and CSS reveals three main alternatives to `html-minifier-terser`: `html-minifier-next`, `@minify-html/node`, and `htmlnano`. `html-minifier-next` stands out as a drop-in successor preserving familiar API and behaviors, while `@minify-html/node` offers maximal performance and robustness against malformed or template-heavy input, albeit with different API and deployment model. `htmlnano` is best for modular, pipeline-driven builds, giving granular control over transformations but requiring additional packages for inline JS/CSS handling. For users satisfied with their current `html-minifier-terser` configuration, maintaining the status quo is reasonable, but those seeking modern alternatives can start with `html-minifier-next`, then consider the others based on desired migration and flexibility.

Key tools:
- [`html-minifier-next`](https://github.com/j9t/html-minifier-next): closest drop-in replacement with updated features.
- [`@minify-html/node`](https://www.npmjs.com/package/@minify-html/node): top choice for speed and template tolerance.

Key findings:
- `html-minifier-next` offers smooth migration and enhanced features, but keeps tree-based parsing limitations.
- `@minify-html/node` tolerates invalid HTML/templates and is fastest, but introduces new deployment/friction.
- `htmlnano` is most modular and tunable, fitting well in PostHTML/bundler pipelines but is not a direct replacement.
- Benchmark claims vary; real-world testing on your own templates is recommended.
