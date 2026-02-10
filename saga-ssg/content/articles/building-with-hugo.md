---
date: 2024-06-10
tags: hugo, tutorial
author: Kevin Renskers
summary: A practical walkthrough of building a simple site with Hugo.
---

# Building a Site with Hugo

Hugo is one of the most popular static site generators. It's written in Go and is known for its speed — even large sites build in milliseconds.

## Getting Started

Install Hugo, create a new site, and you're ready to go:

```sh
hugo new site my-site
cd my-site
hugo server
```

## Content Organization

Hugo uses a simple folder structure. Content goes in `content/`, templates in `layouts/`, and configuration in `hugo.toml`. Sections are created by adding subdirectories to `content/`.

## Templates

Hugo uses Go's `html/template` package. It takes some getting used to, but it's powerful once you learn the patterns.
