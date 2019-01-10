//
//  Repository.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/9/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import Foundation
import Gloss

struct Repository {
    let fullName : String?
    let description : String?
    let starsCount : Int?
    let url : String?
    
    init?(json : JSON) {
         self.fullName = "full_name" <~~ json
         self.description = "description"  <~~ json
         self.starsCount = "stargazers_count" <~~ json
         self.url = "html_url" <~~ json
    }
    
    init?(fullName: String, description: String, starsCount: Int, url: String) {
        self.fullName = fullName
        self.description = description
        self.starsCount = starsCount
        self.url = url
    }
    
}

