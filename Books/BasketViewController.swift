//
//  BasketViewController.swift
//  Books
//
//  Created by Мария on 14.07.17.
//  Copyright © 2017 Мария. All rights reserved.
//

import Foundation
import UIKit

class BasketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var books: [Book] {
        return DatabaseManager.sharedInstance.getBooks(id: User.shared.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tableView.reloadData()
    }
    
    // UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BookCellView = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! BookCellView
        if books.count >= indexPath.row {
            let book = self.books[indexPath.row]
            cell.title.text = book.title
            cell.author.text = book.authors.first
            cell.bookImageView.image = book.image
        }
        
        return cell
    }
    
    // UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if books.count >= indexPath.row {
            let book  = self.books[indexPath.row]
            let vc: BookDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
            vc.book = book
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
