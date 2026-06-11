//
//  Router.swift
//  TesteVIPERsurpresaSeiro
//
//  Created by Thiago on 11/06/26.
//

import UIKit

protocol RouterProtocol: AnyObject {
    func createHomeView() -> UIViewController
    func pushToDetail(from viewController: UIViewController, article: ArticleEntity)
}

class Router: RouterProtocol {

    let apiService: ApiServiceProtocol

    init(apiService: ApiServiceProtocol) {
        self.apiService = apiService
    }

    func createHomeView() -> UIViewController {
        let interactor = InteractorHomeView(api: apiService)
        let presenter = PresenterHomeView(interactor: interactor)
        let view = ViewController(presenter: presenter, router: self)

        presenter.view = view

        return view
    }

    func pushToDetail(from viewController: UIViewController, article: ArticleEntity) {
        let interactor = InteractorDetailView(article: article)
        let presenter = PresenterDetailView(interactor: interactor)
        let detailVC = DetailViewController(presenter: presenter)

        presenter.view = detailVC

        viewController.navigationController?.pushViewController(detailVC, animated: true)
    }
}
