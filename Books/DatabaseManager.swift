//
//  DatabaseManager.swift
//  Books
//
//  Created by Мария on 11.07.17.
//  Copyright © 2017 Мария. All rights reserved.
//

import Foundation
import SQLite

class DatabaseManager {

    static let sharedInstance = DatabaseManager()
    
    private let db: Connection?
    
    private let books = Table("books")
    
    private let id = Expression<Int64>("id")
    private let globalID = Expression<String>("globalID")
    private let title = Expression<String>("title")
    private let authors = Expression<String>("authors")
    private let description = Expression<String?>("description")
    private let image = Expression<Data?>("image")
    private let userID = Expression<String>("userID")
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            db = try Connection("\(path)/Books.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        createTable()
    }
    
    func createTable() {
        do {
            try db!.run(books.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(globalID)
                table.column(title)
                table.column(authors)
                table.column(description)
                table.column(image)
                table.column(userID)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func addBook(bGlobalID: String, bTitle: String, bAuthors: String, bDescription: String?, bImage: UIImage?, bUserID: String) -> Int64? {
        
        let data: Data?
        if let image = bImage {
          data = UIImagePNGRepresentation(image)
        }
        else {
            data = nil
        }
        
     
        do {
            let insert = books.insert(globalID <- bGlobalID, title <- bTitle, authors <- bAuthors, description <- bDescription, image <- data, userID <- bUserID)
            let id = try db!.run(insert)
            
            print(insert.asSQL())
            
            return id
        } catch {
            print("Insert failed")
            return -1
        }
    }
    
    func getBooks() -> [Book] {
        var books = [Book]()
        
        do {
            for book in try db!.prepare(self.books) {
                let bImage: UIImage?
                if let imageData = book[image] {
                    bImage = UIImage(data: imageData)
                }
                else {
                    bImage = nil
                }
                books.append(Book(globalID: book[globalID],
                                  title: book[title],
                                  authors: book[authors].components(separatedBy: ","),
                                  description: book[description],
                                  image: bImage,
                                  userID: book[userID]))
            }
        } catch {
            print("Select failed")
        }
        
        return books
    }
    
    func getBooks(id bUserID: String) -> [Book] {
        var books = [Book]()
        let filteredBooks = self.books.filter(userID == bUserID)
        do {
            for book in try db!.prepare(filteredBooks) {
                let bImage: UIImage?
                if let imageData = book[image] {
                    bImage = UIImage(data: imageData)
                }
                else {
                    bImage = nil
                }
                books.append(Book(globalID: book[globalID],
                                  title: book[title],
                                  authors: book[authors].components(separatedBy: ","),
                                  description: book[description],
                                  image: bImage,
                                  userID: book[userID]))
            }
        } catch {
            print("Select failed")
        }

        return books
    }

    
}
