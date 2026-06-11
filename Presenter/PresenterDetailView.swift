//
//  PresenterDetailView.swift
//  TesteVIPERsurpresaSeiro
//
//  Created by Thiago on 11/06/26.
//

import Foundation

@MainActor
protocol PresenterDetailViewProtocol: AnyObject {
    func viewDidLoad()
}

class PresenterDetailView: PresenterDetailViewProtocol {

    private let interactor: InteractorDetailViewProtocol
    weak var view: DetailViewControllerProtocol?

    init(interactor: InteractorDetailViewProtocol) {
        self.interactor = interactor
    }

    func viewDidLoad() {
        let article = interactor.getArticle()
        view?.showArticle(article)
    }
}
