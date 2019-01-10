//
//  GithubService.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/9/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import Foundation
import Alamofire
typealias JSON = [String : Any]

enum Result<T> {
    case error(Error)
    case success(T)
}

enum ServiceError: Error {
    case cannotParse
}

class GithubService{
    
    static let sharedInstance = GithubService()
    
    func getLanguageList(completionHandler: (Result<[String]>) -> Void) {
        // For simplicity we will use a stubbed list of languages.
        let stubbedListOfPopularLanguages = [
            "Swift",
            "Objective-C",
            "Java",
            "C",
            "C++",
            "Python",
            "C#"
        ]
        
        completionHandler(.success(stubbedListOfPopularLanguages))
    }

    func getMostPopularRepositories(byLanguage language: String, completionHandler: @escaping (Result<[Repository]>) -> Void) {
        let url = "https://api.github.com/search/repositories?q=language:\(language)&sort=stars"
        Alamofire.request(url)
            .responseJSON { (response) in
                //let json = response.result.value as? JSON
                guard let json = response.result.value as? JSON,
                let itemJson = json["items"] as? [JSON]
                else {print("fail"); return}
                
                let repoList = itemJson.compactMap(Repository.init)
                
                completionHandler(.success(repoList))
                
        }
    }
}
