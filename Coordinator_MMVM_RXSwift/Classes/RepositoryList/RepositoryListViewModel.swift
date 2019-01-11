//
//  RepositoryListViewModel.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/11/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class RepositoryListViewModel {
    
    // MARK: - Inputs
    
    /// Call to update current language. Causes reload of the repositories.
    let setCurrentLanguage: AnyObserver<String>
    
    /// Call to show language list screen.
    let chooseLanguage: AnyObserver<Void>
    
    /// Call to open repository page.
    let selectRepository: AnyObserver<RepositoryViewModel>
    
    /// Call to reload repositories.
    let reload: AnyObserver<Void>

    
    // MARK: - Outputs
    
    /// Emits an array of fetched repositories.
    let repositories: Observable<[RepositoryViewModel]>
    
    /// Emits a formatted title for a navigation item.
    let title: Observable<String>
    
    /// Emits an error messages to be shown.
    let alertMessage: Observable<String>
    
    /// Emits an url of repository page to be shown.
    let showRepository: Observable<URL>
    
    /// Emits when we should show language list.
    let showLanguageList: Observable<Void>
    
    init(initialLanguage : String, githubService : GithubService = GithubService.sharedInstance) {
        
        let _reload = PublishSubject<Void>()
        self.reload = _reload.asObserver()
        
        let _setCurrentLanguage = BehaviorSubject<String>(value: initialLanguage)
        self.setCurrentLanguage = _setCurrentLanguage.asObserver()
        
        self.title = _setCurrentLanguage.asObservable().map{"\($0)"}
        
        let _alertMessage = PublishSubject<String>()
        self.alertMessage = _alertMessage.asObservable()
        
        self.repositories = Observable.combineLatest( _reload, _setCurrentLanguage ){ _, language in language}
            .flatMapLatest{ language in githubService.getMostPopularRepositories(byLanguage: language)
                                        .catchError{ error in _alertMessage.onNext(error.localizedDescription)
                                            return Observable.empty()}
            }
            .map{ repo in repo.map(RepositoryViewModel.init)}
        
        let _selectRepository = PublishSubject<RepositoryViewModel>()
        self.selectRepository = _selectRepository.asObserver()
        self.showRepository = _selectRepository.asObservable().map{$0.url}
        
        let _chooseLanguae = PublishSubject<Void>()
        self.chooseLanguage = _chooseLanguae.asObserver()
        self.showLanguageList = _chooseLanguae.asObservable()
    }
}
