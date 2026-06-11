//
//  InteractorHomeView.swift
//  TesteVIPERsurpresaSeiro
//
//  Created by Thiago on 11/06/26.
//

import Foundation

protocol InteractorHomeViewProtocol: AnyObject {
    func fetchPost() async throws -> NewsResponseEntity
}

class InteractorHomeView: InteractorHomeViewProtocol {
    
    let api: ApiServiceProtocol
    
    init(api: ApiServiceProtocol) {
        self.api = api
    }
    
    func fetchPost() async throws -> NewsResponseEntity {
        return try await api.getPosts()
    }
    
    
}
