import Foundation
import HTML
import PathKit
import Saga

// MARK: - Date formatting helper

extension Date {
  func formatted(_ format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: self)
  }
}

// MARK: - Shared layout

func baseLayout(title pageTitle: String, @NodeBuilder children: () -> NodeConvertible) -> Node {
  return [
    .documentType("html"),
    html(lang: "en") {
      head {
        meta(charset: "UTF-8")
        meta(content: "width=device-width, initial-scale=1", name: "viewport")
        title { pageTitle }
        link(href: "/static/style.css", rel: "stylesheet")
        link(href: "/articles/feed.xml", rel: "alternate", title: "RealWorld SSG", type: "application/rss+xml")
      }
      body {
        header {
          nav {
            a(href: "/") { "Home" }
            a(href: "/articles/") { "Articles" }
            a(href: "/projects/") { "Projects" }
            a(href: "/about/") { "About" }
          }
        }

        main {
          children()
        }

        footer {
          p { "RealWorld SSG" }
          a(href: "/articles/feed.xml") { "RSS Feed" }
        }
      }
    }
  ]
}

// MARK: - Page templates

func renderPage(context: ItemRenderingContext<PageMetadata>) -> Node {
  let isHome = context.item.relativeSource == Path("index.md")

  if isHome {
    return renderHome(context: context)
  }

  return baseLayout(title: "\(context.item.title) - RealWorld SSG") {
    h1 { context.item.title }
    Node.raw(context.item.body)
  }
}

func renderHome(context: ItemRenderingContext<PageMetadata>) -> Node {
  let latestArticle = context.allItems
    .compactMap { $0 as? Item<ArticleMetadata> }
    .sorted { $0.date > $1.date }
    .first

  return baseLayout(title: "RealWorld SSG") {
    h1 { "RealWorld SSG" }
    Node.raw(context.item.body)

    if let latestArticle = latestArticle {
      h2 { "Latest Article" }
      article {
        h3 { a(href: latestArticle.url) { latestArticle.title } }
        time(datetime: latestArticle.date.formatted("yyyy-MM-dd")) {
          latestArticle.date.formatted("MMMM d, yyyy")
        }
        if let summary = latestArticle.metadata.summary {
          p { summary }
        }
      }
    }
  }
}

// MARK: - Article templates

func renderArticle(context: ItemRenderingContext<ArticleMetadata>) -> Node {
  baseLayout(title: "\(context.item.title) - RealWorld SSG") {
    article {
      h1 { context.item.title }
      time(datetime: context.item.date.formatted("yyyy-MM-dd")) {
        context.item.date.formatted("MMMM d, yyyy")
      }
      p { "By \(context.item.metadata.author)" }
      if !context.item.metadata.tags.isEmpty {
        ul {
          context.item.metadata.tags.map { tag in
            li { a(href: "/articles/tags/\(tag.slugified)/") { tag } }
          }
        }
      }
      div {
        Node.raw(context.item.body)
      }
    }
  }
}

func renderArticles(context: ItemsRenderingContext<ArticleMetadata>) -> Node {
  baseLayout(title: "Articles - RealWorld SSG") {
    h1 { "Articles" }

    context.items.map { item -> Node in
      article {
        h2 { a(href: item.url) { item.title } }
        time(datetime: item.date.formatted("yyyy-MM-dd")) {
          item.date.formatted("MMMM d, yyyy")
        }
        item.metadata.summary.map { summary in p { summary } } ?? Node.fragment([])
      }
    }

    if let paginator = context.paginator {
      nav {
        if let previous = paginator.previous {
          a(href: previous.url) { "Previous" }
        }
        "Page \(paginator.index) of \(paginator.numberOfPages)"
        if let next = paginator.next {
          a(href: next.url) { "Next" }
        }
      }
    }
  }
}

// MARK: - Tag template

func renderTag(context: PartitionedRenderingContext<String, ArticleMetadata>) -> Node {
  baseLayout(title: "\(context.key) - RealWorld SSG") {
    h1 { "Articles tagged with \"\(context.key)\"" }

    context.items.map { item -> Node in
      article {
        h2 { a(href: item.url) { item.title } }
        time(datetime: item.date.formatted("yyyy-MM-dd")) {
          item.date.formatted("MMMM d, yyyy")
        }
        item.metadata.summary.map { summary in p { summary } } ?? Node.fragment([])
      }
    }
  }
}

// MARK: - Projects template

func renderProjects(context: ItemsRenderingContext<ProjectMetadata>) -> Node {
  return baseLayout(title: "Projects - RealWorld SSG") {
    h1 { "Projects" }
    p { "A collection of open source projects." }

    context.items
      .sorted { ($0.metadata.order, $0.title) < ($1.metadata.order, $1.title) }
      .map { project -> Node in
        article {
          h2 { project.title }
          Node.raw(project.body)
          dl {
            dt { "Category" }
            dd { project.metadata.category }
            dt { "Repository" }
            dd { a(href: project.metadata.repo) { project.metadata.repo } }
          }
        }
      }
  }
}
