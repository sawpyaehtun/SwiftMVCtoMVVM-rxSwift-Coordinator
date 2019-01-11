//
//  RepositoryViewModel.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/11/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import Foundation

class RepositoryViewModel {
    let name: String
    let description: String
    let starsCountText: String
    let url: URL
    
    init(repository: Repository) {
        self.name = repository.fullName!
        self.description = repository.description!
        self.starsCountText = "⭐️ \(repository.starsCount!)"
        self.url = URL(string: repository.url!)!
    }
}
