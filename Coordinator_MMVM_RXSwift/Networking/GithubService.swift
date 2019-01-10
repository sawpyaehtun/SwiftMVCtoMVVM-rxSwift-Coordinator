//
//  GithubService.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/9/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

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
    
    func getLanguageList() -> Observable<[String]> {
        // For simplicity we will use a stubbed list of languages.
        return Observable.just([
            "Swift",
            "Objective-C",
            "Java",
            "C",
            "C++",
            "Python",
            "C#"
            ])
    }

    func getMostPopularRepositories(byLanguage language: String ) -> Observable<[Repository]> {
        let url = "https://api.github.com/search/repositories?q=language:\(language)&sort=stars"
        return Observable<[Repository]>.create({ (observer) -> Disposable in
            let request = Alamofire.request(url).responseJSON(completionHandler: { (response) -> Void in
                guard let json = response.result.value as? JSON,
                    let itemJson = json["items"] as? [JSON]
                    else {print("fail"); return}
                
                let repoList = itemJson.compactMap(Repository.init)
                observer.onNext(repoList)
                observer.onCompleted()
            })
            return Disposables.create {
                request.cancel()
            }
        })
    }
}
