import Foundation
import Plot
import Publish

struct RealWorldSite: Website {
  enum SectionID: String, WebsiteSectionID {
    case articles
    case projects
  }

  struct ItemMetadata: WebsiteItemMetadata {
    var author: String?
    var category: String?
    var repo: String?
    var order: Int?
  }

  var url = URL(string: "https://example.com")!
  var name = "RealWorld SSG"
  var description = "A demo site comparing static site generators."
  var language: Language {
    .english
  }

  var imagePath: Path? {
    nil
  }

  var tagHTMLConfig: TagHTMLConfiguration? {
    .init(basePath: "articles/tags")
  }
}
