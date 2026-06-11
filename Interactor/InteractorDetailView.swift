//
//  InteractorDetailView.swift
//  TesteVIPERsurpresaSeiro
//
//  Created by Thiago on 11/06/26.
//

import Foundation

protocol InteractorDetailViewProtocol: AnyObject {
    func getArticle() -> ArticleEntity
}

class InteractorDetailView: InteractorDetailViewProtocol {

    private let article: ArticleEntity

    init(article: ArticleEntity) {
        self.article = article
    }

    func getArticle() -> ArticleEntity {
        return article
    }
}
