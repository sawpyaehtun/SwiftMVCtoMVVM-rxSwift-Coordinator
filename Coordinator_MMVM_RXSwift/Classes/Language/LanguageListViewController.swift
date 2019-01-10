//
//  LanguageListViewController.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/9/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import UIKit

protocol LanguageListViewControllerDelegate: class {
    func languageListViewController(_ viewController: LanguageListViewController, didSelectLanguage language: String)
    func languageListViewControllerDidCancel(_ viewController: LanguageListViewController)
}

class LanguageListViewController: UIViewController {

    var delegate : LanguageListViewControllerDelegate?
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var languageTable: UITableView!
    fileprivate var languages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        loadData()

        refreshControl.addTarget(self, action: #selector(LanguageListViewController.loadData), for: .valueChanged)
    }
    
    private func setUpUI(){
        self.title = "Languages"
        let cancleButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(LanguageListViewController.cancle))
        
        navigationItem.leftBarButtonItem = cancleButton
        
        languageTable.register(UINib(nibName: String(describing: LanguageTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: LanguageTableViewCell.self))
    }
    
    @objc private func cancle(){
        delegate?.languageListViewControllerDidCancel(self)
    }
    
    @objc private func loadData() {
        GithubService.sharedInstance.getLanguageList { [weak self] result in
            guard case let .success(newLanguages) = result else { return }
            self?.languages = newLanguages
            self?.languageTable.reloadData()
        }
    }

}

extension LanguageListViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LanguageTableViewCell.self), for: indexPath) as! LanguageTableViewCell
        cell.setUpCellUI(language: languages[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension LanguageListViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.languageListViewController(self, didSelectLanguage: languages[indexPath.row])
    }
}
