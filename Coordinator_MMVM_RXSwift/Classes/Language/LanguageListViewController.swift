//
//  LanguageListViewController.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/9/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LanguageListViewController: UIViewController {

    let disposeBag = DisposeBag()
    let cancleButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    private let _cancle = PublishSubject<Void>()
    var didCancle : Observable<Void> {return _cancle.asObservable()}
    
    private let _selectedLanguage = PublishSubject<String>()
    var didSelectedLanguage : Observable<String> {return _selectedLanguage.asObservable()}
    
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var languageTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpBinding()
    }
    
    private func setUpUI(){
        self.title = "Languages"
        navigationItem.leftBarButtonItem = cancleButton
        languageTable.register(UINib(nibName: String(describing: LanguageTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: LanguageTableViewCell.self))
    }
    
    private func setUpBinding() {
        let languages = GithubService.sharedInstance.getLanguageList()
        
        languages.bind(to: languageTable.rx.items(cellIdentifier: String(describing: LanguageTableViewCell.self), cellType: LanguageTableViewCell.self)){( _, language, cell) in
            cell.setUpCellUI(language: language)
            }
            .disposed(by: disposeBag)
        
        languageTable.rx.modelSelected(String.self).bind(to: _selectedLanguage)
        .disposed(by: disposeBag)
        
        cancleButton.rx.tap.bind(to: _cancle).disposed(by: disposeBag)
    }
}
