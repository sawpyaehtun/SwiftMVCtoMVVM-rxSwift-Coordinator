//
//  ViewController.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/9/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import UIKit
import SafariServices

class RepositoryListViewController: UIViewController {
    @IBOutlet weak var repoListTableView: UITableView!
    private var refreshControl = UIRefreshControl()
    private enum SegueType : String{
        case showLanguageList = "showLanguageList"
    }
    
    private var currentLanguage = "Swift"
    private var currentRepoList = [Repository]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    @objc private func fetchData(){
        refreshControl.beginRefreshing()
        GithubService.sharedInstance.getMostPopularRepositories(byLanguage: currentLanguage){ [weak self] result in
            switch result {
            case let .error(error):
                self?.printResult(res: error)
            case let .success(newRepositories):
                self?.reloadRepoList(data : newRepositories)
            }
    }
    }
    
    private func reloadRepoList(data : [Repository]){
        refreshControl.endRefreshing()
        self.title = currentLanguage
        self.currentRepoList = data
       self.repoListTableView.reloadData()
    }
    
    private func printResult(res : Any){
        print(res)
    }

    private func setupUI() {
        refreshControl.addTarget(self, action: #selector(RepositoryListViewController.fetchData), for: .valueChanged)
        let chooseLanguageButton = UIBarButtonItem(barButtonSystemItem: .organize,
                                                   target: self,
                                                   action: #selector(RepositoryListViewController.openLanguageList))
        navigationItem.rightBarButtonItem = chooseLanguageButton
        
        repoListTableView.register(UINib(nibName: String(describing: RepositoryTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RepositoryTableViewCell.self))
        
        repoListTableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc
    private func openLanguageList() {
        performSegue(withIdentifier: SegueType.showLanguageList.rawValue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC: UIViewController? = segue.destination
        
        if let nvc = destinationVC as? UINavigationController {
            destinationVC = nvc.viewControllers.first
        }
        
        if let viewController = destinationVC as? LanguageListViewController, segue.identifier == SegueType.showLanguageList.rawValue {
            viewController.delegate = self
        }
    }

}

extension RepositoryListViewController : LanguageListViewControllerDelegate{
    func languageListViewController(_ viewController: LanguageListViewController, didSelectLanguage language: String) {
        currentLanguage = language
        fetchData()
        dismiss(animated: true, completion: nil)
    }
    
    func languageListViewControllerDidCancel(_ viewController: LanguageListViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension RepositoryListViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let repository = currentRepoList[indexPath.row]
            let url = URL(string: repository.url!)
            let safariViewController = SFSafariViewController(url: url!)
            navigationController?.pushViewController(safariViewController, animated: true)
    }
}

extension RepositoryListViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentRepoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepositoryTableViewCell.self), for: indexPath) as! RepositoryTableViewCell
        let repo = currentRepoList[indexPath.row]
        cell.selectionStyle = .none
        cell.setName(name: repo.fullName!)
        cell.setDescription(des: repo.description!)
        let count = "⭐️ \(repo.starsCount!)"
        cell.starCount(starCount: count)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
