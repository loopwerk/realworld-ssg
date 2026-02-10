import Saga

struct ArticleMetadata: Metadata {
  let tags: [String]
  let author: String
  let summary: String?
}

struct ProjectMetadata: Metadata {
  let category: String
  let repo: String
  let order: Int
}

struct PageMetadata: Metadata {}
