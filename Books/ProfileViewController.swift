//
//  ProfileViewController.swift
//  Books
//
//  Created by Мария on 14.07.17.
//  Copyright © 2017 Мария. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = User.shared.name
        self.imageView.image = User.shared.image
    }
}
