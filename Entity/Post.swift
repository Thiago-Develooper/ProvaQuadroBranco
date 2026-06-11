//
//  Post.swift
//  TesteVIPERsurpresaSeiro
//
//  Created by Thiago on 11/06/26.
//

struct NewsResponseEntity: Decodable {
    let status: String
    let totalResults: Int
    let articles: [ArticleEntity]
}

struct ArticleEntity: Decodable {
    let source: SourceEntity
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct SourceEntity: Decodable {
    let id: String?
    let name: String
}
