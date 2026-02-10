# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A comparison project implementing the same website with three static site generators: **Hugo** (Go), **Saga** (Swift), and **Publish** (Swift). All three produce identical HTML output with the same URLs and structure. Companion to an article at loopwerk.io.

The site has: a home page, paginated blog (5 articles, 2 per page), tag pages, an Atom/RSS feed, a projects listing, and an about page. No CSS — focus is on SSG mechanics.

## Build Commands

```bash
# Build all three implementations
just build-all

# Clean all build outputs
just clean-all

# Per-project (from repo root)
cd hugo && just build        # Requires Hugo CLI
cd saga-ssg && just build    # Runs `swift run`
cd publish-ssg && just build # Runs `swift run`

# Each project also has: just clean, just serve
```

Build outputs: `hugo/public/`, `saga-ssg/deploy/`, `publish-ssg/Output/`.

## Architecture

### Hugo (`hugo/`)
- Template-driven using Go `html/template` in `layouts/`
- Config in `hugo.toml` (pagination=2, year-based permalinks)
- Content in `content/` with TOML frontmatter

### Saga (`saga-ssg/`)
- Pipeline-driven Swift SSG using Saga 2.3.0, SagaParsleyMarkdownReader, SagaSwimRenderer
- `run.swift` — entry point; registers content folders with metadata types, readers, writers
- `Metadata.swift` — `ArticleMetadata`, `ProjectMetadata`, `PageMetadata` structs
- `ItemProcessors.swift` — custom permalink processor (adds year to article paths)
- `Templates.swift` — all HTML templates using Swim DSL
- Content in `content/` with simple key-value frontmatter

### Publish (`publish-ssg/`)
- Step-based Swift SSG using Publish 0.9.0
- `main.swift` — chains publishing steps (parse → sort → generate → post-process)
- `RealWorldSite.swift` — site definition with `SectionID` enum and `ItemMetadata`
- `PublishingSteps.swift` — custom steps: year-in-paths, pagination, feed relocation
- `HTMLFactory.swift` — implements `HTMLFactory` protocol using Plot DSL
- Content in `Content/` with YAML frontmatter

## Key Conventions

- **Swim DSL (Saga):** Use native HTML elements (`article { }`, `nav { }`) instead of `Node.raw("<article>")`. The DSL supports most elements directly.
- **Plot DSL (Publish):** Use type-safe APIs (`.link(.rel(.alternate), .type(...), .href(...))`) instead of `.raw()` strings. Only use `.raw()` for rendered markdown body HTML.
- Content is duplicated across implementations (not shared) with slightly different frontmatter formats per SSG.
- Swift formatting rules in `.swiftformat`: 2-space indent, inline pattern let.
