//
//  UserDataInstance.swift
//  Books
//
//  Created by Мария on 11.07.17.
//  Copyright © 2017 Мария. All rights reserved.
//

import Foundation

import UIKit

final class User {
    
    private init() { }
    
    static let shared = User()
    
    var id: String! = nil
    var name: String = ""
    var image: UIImage? = nil
    
    public func isLoggedIn() -> Bool {
        return id != nil
    }
}
