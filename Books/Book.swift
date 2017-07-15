//
//  Book.swift
//  Books
//
//  Created by Мария on 11.07.17.
//  Copyright © 2017 Мария. All rights reserved.
//

import Foundation
import UIKit

class Book {
    let globalID: String
    let title: String
    let authors: [String]
    let description: String?
    let image: UIImage?
    let userID: String
    
    init(globalID: String, title: String, authors: [String], description: String?, image: UIImage?, userID: String) {
        self.globalID = globalID
        self.title = title
        self.authors = authors
        self.description = description
        self.image = image
        self.userID = userID
    }
    
    func saveToDatabase(){
        let authorsStringRepresentation = authors.joined(separator: ",")
        print("add book result", DatabaseManager.sharedInstance.addBook(bGlobalID: globalID, bTitle: title, bAuthors: authorsStringRepresentation, bDescription: description, bImage: image, bUserID: userID) ?? 0)
    }
}
