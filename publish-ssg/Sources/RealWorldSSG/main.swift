import Publish

let factory = RealWorldHTMLFactory()

try RealWorldSite().publish(using: [
  .copyResources(),
  .addMarkdownFiles(),
  .sortItems(by: \.date, order: .descending),
  .generateHTML(withTheme: Theme(htmlFactory: factory)),
  .generatePaginatedArticles(factory: factory),
  .generateRSSFeed(
    including: [.articles],
    config: .init(targetPath: "articles/feed.xml")
  ),
  .removeProjectPages(),
])
