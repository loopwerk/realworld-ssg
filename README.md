# realworld-ssg

The same static site, built with three different static site generators:

- [Hugo](https://gohugo.io) — Go-based, the most popular SSG
- [Saga](https://github.com/loopwerk/Saga) — Swift-based, code-driven pipeline
- [Publish](https://github.com/JohnSundell/Publish) — Swift-based, by John Sundell

Same content. Same URLs. Same output. Different tools.

This is the companion repo for my [article on loopwerk.io](https://www.loopwerk.io/articles/2026/hugo-vs-publish-vs-saga/).

## The site

A minimal but realistic static site with:

- A **home page** with a link to the latest article
- A **blog** with 5 articles, paginated (2 per page), with tags and summaries
- **Tag pages** listing all articles for a given tag (e.g. `/articles/tags/swift/`)
- An **Atom/RSS feed** for the blog
- A **projects** page listing open source projects
- An **about** page
- Article URLs include the publication year: `/articles/2024/my-post/`
- A **contact** page, fully programmatically created (not from a markdown file).
- Cache-busting CSS filename.

No fancy CSS. No themes. Just semantic HTML — the focus is on the SSG mechanics.

## Requirements

- [just](https://github.com/casey/just) command runner
- [Hugo](https://gohugo.io/installation/) (for the Hugo version)
- [Swift 5.9+](https://swift.org) (for Saga and Publish)

## Usage

Build a single SSG:

```sh
cd hugo && just build
cd saga-ssg && just build
cd publish-ssg && just build
```

Build all:

```sh
just build-all
```

Clean all generated output:

```sh
just clean-all
```
