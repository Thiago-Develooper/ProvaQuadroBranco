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
        
        do {
            let response = try await interactor.fetchPost()
            let posts = response.articles
            view?.showPosts(posts)
        } catch {
            print(error.localizedDescription)
            view?.showError(error.localizedDescription)
        }
    }
    
    
}
