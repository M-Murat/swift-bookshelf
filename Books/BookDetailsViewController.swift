//
//  BookDetailsViewController.swift
//  Books
//
//  Created by Мария on 12.07.17.
//  Copyright © 2017 Мария. All rights reserved.
//

import Foundation
import UIKit

class BookDetailsViewController: UIViewController {
    
    public var book: Book!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addToBasketButton: UIButton!
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        if self.navigationController?.previousViewController() is BasketViewController {
           self.addToBasketButton.isHidden = true
        }
        
        self.titleLabel.text = self.book.title
        self.authorsLabel.text = self.book.authors.joined(separator: ", ")
        self.imageView.image = self.book.image
        self.descriptionTextView.text = self.book.description
    }
    
    
    @IBAction func addToBasketPressed(_ sender: Any) {
        self.book.saveToDatabase()
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}

extension UINavigationController {
    
    func previousViewController() -> UIViewController? {
        guard viewControllers.count > 1 else {
            return nil
        }
        return viewControllers[viewControllers.count - 2]
    }
    
}
