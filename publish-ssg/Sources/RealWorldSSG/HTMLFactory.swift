import Foundation
import Plot
import Publish

// MARK: - Date helpers

extension Date {
  func formatted(_ format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: self)
  }
}

// MARK: - Helpers

func baseLayout(title: String, _ content: Node<HTML.BodyContext>) -> HTML {
  HTML(
    .lang(.english),
    .head(
      .encoding(.utf8),
      .viewport(.accordingToDevice),
      .title(title),
      .link(.rel(.stylesheet), .href("/style.css")),
      .link(.rel(.alternate), .type("application/rss+xml"), .title("RealWorld SSG"), .href("/articles/feed.xml"))
    ),
    .body(
      .header(
        .nav(
          .a(.href("/"), .text("Home")),
          .a(.href("/articles/"), .text("Articles")),
          .a(.href("/projects/"), .text("Projects")),
          .a(.href("/about/"), .text("About"))
        )
      ),
      .main(content),
      .footer(
        .p("RealWorld SSG"),
        .a(.href("/articles/feed.xml"), .text("RSS Feed"))
      )
    )
  )
}

func articlePath(_ item: Item<RealWorldSite>) -> String {
  "/\(item.path)/"
}

// MARK: - HTML Factory

struct RealWorldHTMLFactory: HTMLFactory {
  typealias Site = RealWorldSite

  func makeIndexHTML(for _: Index, context: PublishingContext<Site>) throws -> HTML {
    let latestArticle = context.allItems(sortedBy: \.date, order: .descending)
      .first { $0.sectionID == .articles }

    return baseLayout(title: context.site.name, .group(
      .h1(.text("RealWorld SSG")),
      .p(
        .text("Welcome to the RealWorld SSG demo site. This site is built to compare static site generators.")
      ),
      .p(
        .text("Browse the "),
        .a(.href("/articles/"), .text("articles")),
        .text(" or check out our "),
        .a(.href("/projects/"), .text("open source projects")),
        .text(".")
      ),
      .unwrap(latestArticle) { latestArticle in
        .group(
          .h2(.text("Latest Article")),
          .article(
            .h3(.a(.href(articlePath(latestArticle)), .text(latestArticle.title))),
            .time(.datetime(latestArticle.date.formatted("yyyy-MM-dd")), .text(latestArticle.date.formatted("MMMM d, yyyy"))),
            .if(!latestArticle.description.isEmpty, .p(.text(latestArticle.description)))
          )
        )
      }
    ))
  }

  func makeSectionHTML(for section: Publish.Section<Site>, context: PublishingContext<Site>) throws -> HTML {
    switch section.id {
      case .articles:
        return makeArticlesListHTML(items: section.items.sorted { $0.date > $1.date }, context: context, page: 1)
      case .projects:
        return makeProjectsHTML(for: section, context: context)
    }
  }

  func makeItemHTML(for item: Item<Site>, context: PublishingContext<Site>) throws -> HTML {
    baseLayout(title: "\(item.title) - \(context.site.name)", .article(
      .h1(.text(item.title)),
      .time(.datetime(item.date.formatted("yyyy-MM-dd")), .text(item.date.formatted("MMMM d, yyyy"))),
      .unwrap(item.metadata.author) { author in
        .p(.text("By \(author)"))
      },
      .if(
        !item.tags.isEmpty,
        .ul(.forEach(item.tags.sorted()) { tag in
          .li(.a(.href(context.site.path(for: tag).absoluteString), .text(tag.string)))
        })
      ),
      .div(.raw(item.body.html))
    ))
  }

  func makePageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
    baseLayout(title: "\(page.content.title) - \(context.site.name)", .group(
      .h1(.text(page.content.title)),
      .div(.raw(page.content.body.html))
    ))
  }

  func makeTagListHTML(for _: TagListPage, context _: PublishingContext<Site>) throws -> HTML? {
    nil
  }

  func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws -> HTML? {
    let items = context.items(taggedWith: page.tag, sortedBy: \.date, order: .descending)

    return baseLayout(title: "\(page.tag.string) - \(context.site.name)", .group(
      .h1(.text("Articles tagged with \"\(page.tag.string)\"")),
      .forEach(items) { item in
        .article(
          .h2(.a(.href(articlePath(item)), .text(item.title))),
          .time(.datetime(item.date.formatted("yyyy-MM-dd")), .text(item.date.formatted("MMMM d, yyyy"))),
          .if(!item.description.isEmpty, .p(.text(item.description)))
        )
      }
    ))
  }

  // MARK: - Article list with pagination

  func makeArticlesListHTML(items allItems: [Item<Site>], context: PublishingContext<Site>, page: Int) -> HTML {
    let perPage = 2
    let totalPages = Int(ceil(Double(allItems.count) / Double(perPage)))
    let startIndex = (page - 1) * perPage
    let endIndex = min(startIndex + perPage, allItems.count)
    let pageItems = Array(allItems[startIndex ..< endIndex])

    return baseLayout(title: "Articles - \(context.site.name)", .group(
      .h1(.text("Articles")),
      .forEach(pageItems) { item in
        .article(
          .h2(.a(.href(articlePath(item)), .text(item.title))),
          .time(.datetime(item.date.formatted("yyyy-MM-dd")), .text(item.date.formatted("MMMM d, yyyy"))),
          .if(!item.description.isEmpty, .p(.text(item.description)))
        )
      },
      .nav(
        .if(page > 1, .a(
          .href(page == 2 ? Path("/articles/") : Path("/articles/page/\(page - 1)/")),
          .text("Previous")
        )),
        .text("Page \(page) of \(totalPages)"),
        .if(page < totalPages, .a(
          .href(Path("/articles/page/\(page + 1)/")),
          .text("Next")
        ))
      )
    ))
  }

  // MARK: - Projects list

  func makeProjectsHTML(for section: Publish.Section<Site>, context: PublishingContext<Site>) -> HTML {
    let sorted = section.items.sorted { ($0.metadata.order ?? 1, $0.title) < ($1.metadata.order ?? 1, $1.title) }

    return baseLayout(title: "Projects - \(context.site.name)", .group(
      .h1(.text("Projects")),
      .p(.text("A collection of open source projects.")),
      .forEach(sorted) { project in
        .article(
          .h2(.text(project.title)),
          .div(.raw(project.body.html)),
          .dl(
            .dt(.text("Category")),
            .dd(.text(project.metadata.category ?? "")),
            .dt(.text("Repository")),
            .dd(
              .unwrap(project.metadata.repo) { repo in
                .a(.href(repo), .text(repo))
              }
            )
          )
        )
      }
    ))
  }
}
