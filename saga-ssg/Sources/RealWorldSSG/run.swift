import Foundation
import Saga
import SagaParsleyMarkdownReader
import SagaSwimRenderer

@main
struct Run {
  static func main() async throws {
    try await Saga(input: "content", output: "deploy")
      .register(
        folder: "articles",
        metadata: ArticleMetadata.self,
        readers: [.parsleyMarkdownReader],
        itemProcessor: permalink,
        writers: [
          .itemWriter(swim(renderArticle)),
          .listWriter(swim(renderArticles), paginate: 2),
          .tagWriter(swim(renderTag), output: "tags/[key]/index.html", tags: \.metadata.tags),
          .listWriter(atomFeed(title: "RealWorld SSG", baseURL: URL(string: "https://example.com")!, summary: \.metadata.summary), output: "feed.xml"),
        ]
      )
      .register(
        folder: "projects",
        metadata: ProjectMetadata.self,
        readers: [.parsleyMarkdownReader],
        writers: [
          .listWriter(swim(renderProjects)),
        ]
      )
      .register(
        metadata: PageMetadata.self,
        readers: [.parsleyMarkdownReader],
        writers: [
          .itemWriter(swim(renderPage)),
        ]
      )
      .run()
      .staticFiles()
  }
}
