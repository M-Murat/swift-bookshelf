//
//  BooksViewController.swift
//  Books
//
//  Created by Мария on 09.07.17.
//  Copyright © 2017 Мария. All rights reserved.
//

import UIKit
import Foundation
import GoogleBooksApiClient
import AlamofireImage
import Alamofire

let session = URLSession.shared
let client = GoogleBooksApiClient(session: session)

class BooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // flags to check if searching is finished and
    // to search again if any searching was delayed
    var isSearching = false
    var isDelayedSearching = false
    var page = 0
    
    var books: [Volume] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BookCellView = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! BookCellView
        
        if books.count >= indexPath.row {
            let book = self.books[indexPath.row]

            cell.title.text = book.volumeInfo.title
            cell.author.text = book.volumeInfo.authors.first
            
            if let url = book.volumeInfo.imageLinks?.thumbnail ??  book.volumeInfo.imageLinks?.smallThumbnail {
                var strUrl = url.absoluteString
                let index = strUrl.index(strUrl.startIndex, offsetBy: 4)
                if !(strUrl.substring(to: index) == "https"){
                    strUrl = strUrl.substring(from: index)
                    strUrl = "https" + strUrl
                }
                if let apdatedUrl = URL(string: strUrl) {
                    cell.bookImageView.af_setImage(withURL: apdatedUrl, placeholderImage: UIImage(named:"loader"),  imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion:nil)
                }
            }
        }
        return cell
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.startNewSearch()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                    self.loadNewPage()
    }
    
    func startNewSearch() {
        self.books = []
        self.page = 0
        let searchText = self.searchBar.text ?? " "
        if isSearching {
            isDelayedSearching = true
        }
        else {
            let req = GoogleBooksApi.VolumeRequest.List(query: searchText)
            let task: URLSessionDataTask = client.invoke(
                req,
                onSuccess: { volumes in
                    self.books = volumes.items
                    self.isSearching = false
                    if self.isDelayedSearching {
                        self.isDelayedSearching = false
                        self.startNewSearch()
                    }},
                onError: { error in print(error)
                    self.isSearching = false
                    if self.isDelayedSearching {
                        self.isDelayedSearching = false
                        self.startNewSearch()
                    }}
            )
            self.isSearching = true
            task.resume()
        }
    }
    
    func loadNewPage(){
        self.page += 1
        let searchText = self.searchBar.text ?? " "
        let req = GoogleBooksApi.VolumeRequest.List(query: searchText, startIndex: self.page * 10)
        let task: URLSessionDataTask = client.invoke(
            req,
            onSuccess: { volumes in
                self.books += volumes.items },
            onError: { error in print(error)}
        )
        task.resume()
    }
    
    // UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if books.count >= indexPath.row {
            let detailedBook = self.books[indexPath.row]
            let cell:BookCellView = self.tableView.cellForRow(at: indexPath) as! BookCellView
            let book = Book(globalID: detailedBook.id.value, title: detailedBook.volumeInfo.title, authors: detailedBook.volumeInfo.authors, description: detailedBook.volumeInfo.desc, image: cell.bookImageView.image, userID: User.shared.id)
            
            let vc: BookDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
            vc.book = book
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
