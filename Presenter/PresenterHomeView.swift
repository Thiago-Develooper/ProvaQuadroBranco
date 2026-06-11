//
//  PresenterHomeView.swift
//  TesteVIPERsurpresaSeiro
//
//  Created by Thiago on 11/06/26.
//

import UIKit

@MainActor
protocol PresenterHomeViewProtocol: AnyObject {
    func fetchPosts() async
}

class PresenterHomeView: PresenterHomeViewProtocol {

    var interactor: InteractorHomeViewProtocol
    weak var view: HomeViewControllerProtocol?

    init(view: HomeViewControllerProtocol? = nil, interactor: InteractorHomeViewProtocol) {
        self.interactor = interactor
        self.view = view
    }

    func fetchPosts() async {
        view?.showLoading()
        do {
            let response = try await interactor.fetchPost()
            view?.hideLoading()
            view?.showPosts(response.articles)
        } catch {
            view?.hideLoading()
            view?.showError(error.localizedDescription)
        }
    }
}
