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
    
    var viewModel : LanguageListViewModel!
    
    let cancleButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
    @IBOutlet weak var languageTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpBinding()
    }
    
    private func setUpUI(){
        navigationItem.title = "Languages"
        navigationItem.leftBarButtonItem = cancleButton
        
        languageTable.register(UINib(nibName: String(describing: LanguageTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: LanguageTableViewCell.self))
    }
    
    private func setUpBinding() {
        
        viewModel.languages.observeOn(MainScheduler.instance)
            .bind(to: languageTable.rx.items(cellIdentifier: String(describing: LanguageTableViewCell.self), cellType: LanguageTableViewCell.self)){ _, language, cell in
                cell.setUpCellUI(language: language)
        }
        .disposed(by: disposeBag)
        
        
        languageTable.rx.modelSelected(String.self).bind(to: viewModel.selectLanguage)
        .disposed(by: disposeBag)
        
        cancleButton.rx.tap.bind(to: viewModel.cancle).disposed(by: disposeBag)
    }
}
