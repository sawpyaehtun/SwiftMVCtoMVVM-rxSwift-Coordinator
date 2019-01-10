//
//  RepositoryTableViewCell.swift
//  Coordinator_MMVM_RXSwift
//
//  Created by SawPyaeHtun on 1/9/19.
//  Copyright © 2019 SawPyaeHtun. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var starCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setName (name : String){
        nameLabel.numberOfLines = 0
        nameLabel.text = name
    }
    
    func setDescription(des : String) {
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = des
    }
    
    func starCount (starCount : String ) {
        starCountLabel.numberOfLines = 0
        starCountLabel.text = starCount
    }
}
