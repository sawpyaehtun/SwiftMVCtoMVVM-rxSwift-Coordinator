//
//  ViewController.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/9/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxCocoa

class RepositoryListViewController: UIViewController {
    
    private enum SegueType : String{
        case showLanguageList = "showLanguageList"
    }
    
    @IBOutlet weak var repoListTableView: UITableView!
    private let repositoryListViewModel = RepositoryListViewModel(initialLanguage: "Swift")
    private let chooseLanguageButton = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: nil)

    private var refreshControl = UIRefreshControl()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpBindings()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = chooseLanguageButton
        
        repoListTableView.register(UINib(nibName: String(describing: RepositoryTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RepositoryTableViewCell.self))
        
        repoListTableView.insertSubview(refreshControl, at: 0)
    }
    
    private func setUpBindings(){
        //viewmodel output to the viewController
        
        repositoryListViewModel.repositories.observeOn(MainScheduler.instance)
            .do(onNext: {[weak self] _ in self?.refreshControl.endRefreshing()})
            .bind(to: repoListTableView.rx.items(cellIdentifier: String(describing: RepositoryTableViewCell.self), cellType: RepositoryTableViewCell.self)){[weak self] (_,repo,cell) in
            self?.setupRepositoryCell(cell,repository : repo)
        }.disposed(by: disposeBag)
        
        repositoryListViewModel.title.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        
        repositoryListViewModel.showRepository.subscribe(onNext : { [weak self] in self?.openRepository(url: $0)
        }).disposed(by: disposeBag)
        
        repositoryListViewModel.showLanguageList.subscribe(onNext : {[weak self] in
            self?.openLanguageList()
        }).disposed(by: disposeBag)
        
        repositoryListViewModel.alertMessage.subscribe(onNext : {[weak self] in
            self?.presentAlert(message: $0)
        }).disposed(by: disposeBag)
        
        // view Controller UI action to view Model
        
        refreshControl.rx.controlEvent(.valueChanged).bind(to: repositoryListViewModel.reload).disposed(by: disposeBag)
        
        chooseLanguageButton.rx.tap.bind(to: repositoryListViewModel.chooseLanguage).disposed(by: disposeBag)
        
        repoListTableView.rx.modelSelected(RepositoryViewModel.self)
        .bind(to: repositoryListViewModel.selectRepository).disposed(by: disposeBag)
        
        
    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    private func setupRepositoryCell(_ cell: RepositoryTableViewCell, repository: RepositoryViewModel) {
        cell.selectionStyle = .none
        cell.setName(name: repository.name)
        cell.setDescription(des: repository.description)
        cell.setStarCount(starCount: repository.starsCountText)
    }
    
    private func openRepository(url : URL) {
        let safariViewController = SFSafariViewController(url: url)
        navigationController?.pushViewController(safariViewController, animated: true)
    }

//    private func presentAlert(message: String) {
//        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alertController, animated: true)
//    }
//
    private func openLanguageList() {
        performSegue(withIdentifier: SegueType.showLanguageList.rawValue, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC: UIViewController? = segue.destination
        
        if let nvc = destinationVC as? UINavigationController {
            destinationVC = nvc.viewControllers.first
        }

        if let viewController = destinationVC as? LanguageListViewController, segue.identifier == SegueType.showLanguageList.rawValue {
            prepareLanguageListViewController(viewController)
        }
    }



private func prepareLanguageListViewController(_ viewController: LanguageListViewController) {
    
    let languageListViewModel = LanguageListViewModel()
    
    let dismiss = Observable.merge([
        languageListViewModel.didCancle,
        languageListViewModel.didSelect.map { _ in }
        ])
    
    dismiss
        .subscribe(onNext: { _ in viewController.dismiss(animated: true) })
        .disposed(by: viewController.disposeBag)
    
    languageListViewModel.didSelect.bind(to: repositoryListViewModel.setCurrentLanguage).disposed(by: viewController.disposeBag)
    viewController.viewModel = languageListViewModel
}
}
