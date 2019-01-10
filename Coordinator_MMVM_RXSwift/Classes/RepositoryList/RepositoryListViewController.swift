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
    @IBOutlet weak var repoListTableView: UITableView!
    private var refreshControl = UIRefreshControl()
    private let disposeBag = DisposeBag()
    private let chooseLanguageButton = UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: nil)
    private enum SegueType : String{
        case showLanguageList = "showLanguageList"
    }
    
    fileprivate var currentLanguage = BehaviorSubject(value: "Swift")
    
    private var currentRepoList = [Repository]()
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
        let reload = refreshControl.rx.controlEvent(.valueChanged).asObservable()
        let repositories = Observable.combineLatest(reload.startWith().debug(),currentLanguage.debug()){ _, language in return language}.debug()
            .flatMap{ [unowned self] in
                GithubService.sharedInstance.getMostPopularRepositories(byLanguage: $0)
                .observeOn(MainScheduler.instance)
                    .catchError { error in
                        self.presentAlert(message: error.localizedDescription)
                        return .empty()
                }
                    .do(onNext: { [weak self] _ in
                        self?.refreshControl.endRefreshing()
                    })
        }
        
        repositories.bind(to: repoListTableView.rx.items(cellIdentifier: String(describing: RepositoryTableViewCell.self), cellType: RepositoryTableViewCell.self)){ (_ , repo , cell) in
            cell.selectionStyle = .none
                    cell.setName(name: repo.fullName!)
                    cell.setDescription(des: repo.description!)
                    let count = "⭐️ \(repo.starsCount!)"
                    cell.starCount(starCount: count)
        }.disposed(by: disposeBag)
        
        currentLanguage.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
        repoListTableView.rx.modelSelected(Repository.self).subscribe(onNext: { [weak self] in
            self?.openRepository($0)
            })
        .disposed(by: disposeBag)
        
        chooseLanguageButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.openLanguageList()
            })
            .disposed(by: disposeBag)
    }
    
    private func openRepository(_ repository: Repository) {
        let url = URL(string: repository.url!)!
        let safariViewController = SFSafariViewController(url: url)
        navigationController?.pushViewController(safariViewController, animated: true)
    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
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
    
    let dismiss = Observable.merge([
        viewController.didCancle,
        viewController.didSelectedLanguage.map { _ in }
        ])
    
    dismiss
        .subscribe(onNext: { _ in viewController.dismiss(animated: true) })
        .disposed(by: viewController.disposeBag)
    
    viewController.didSelectedLanguage
        .bind(to: currentLanguage)
        .disposed(by: viewController.disposeBag)
}
}
