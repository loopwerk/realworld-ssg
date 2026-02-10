import Foundation
import Publish

extension PublishingStep where Site == RealWorldSite {
  /// Generate paginated article list pages (page 2+)
  static func generatePaginatedArticles(factory: RealWorldHTMLFactory) -> Self {
    .step(named: "Generate paginated articles") { context in
      let allItems = context.sections[.articles].items.sorted { $0.date > $1.date }
      let perPage = 2
      let totalPages = Int(ceil(Double(allItems.count) / Double(perPage)))

      for page in 2 ... totalPages {
        let html = factory.makeArticlesListHTML(items: allItems, context: context, page: page)
        let path = Path("articles/page/\(page)/index.html")
        try context.createOutputFile(at: path).write(html.render())
      }
    }
  }

  /// Remove individual project pages (we only want the listing)
  static func removeProjectPages() -> Self {
    .step(named: "Remove project pages") { context in
      let items = context.sections[.projects].items
      for item in items {
        let slug = item.path.string.replacingOccurrences(of: "projects/", with: "")
        try context.outputFile(at: "projects/\(slug)/index.html").parent?.delete()
      }
    }
  }
}
