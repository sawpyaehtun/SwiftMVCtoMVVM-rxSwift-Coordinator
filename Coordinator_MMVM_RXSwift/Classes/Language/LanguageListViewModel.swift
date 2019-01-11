//
//  LanguageListViewModel.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/11/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class LanguageListViewModel{
    //input
    let selectLanguage : AnyObserver<String>
    let cancle : AnyObserver<Void>
    
    //output
    let languages : Observable<[String]>
    let didSelect : Observable<String>
    let didCancle : Observable<Void>
    
    init(githubService : GithubService = GithubService.sharedInstance) {
        //fetch the data from service
        self.languages = githubService.getLanguageList()
        
        //create a rx publisherSubject
        let _selectLanguage = PublishSubject<String>()
        //assign publisherSubject.asObserver() to selectLanguage
        self.selectLanguage = _selectLanguage.asObserver()
        //assign publisherSubject.asObserable() to didSelect
        self.didSelect = _selectLanguage.asObservable()
        
        //create a rx publisherSubject
        let _cancle = PublishSubject<Void>()
        //assign publisherSubject.asObserver() to cancle
        self.cancle = _cancle.asObserver()
        //assign publisherSubject.asObserable() to didCancle
        self.didCancle = _cancle.asObservable()
    }
    
}
