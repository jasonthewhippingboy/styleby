//
//  User.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation

struct User: FirebaseType {
    
    static let userKey = "user"
    private let kUsername = "username"
    private let kFirstName = "firstName"
    private let kLastName = "lastName"
    private let kEmail = "email"
    private let kPassword = "password"
    private let kBio = "bio"
    private let kURL = "url"
    
    var username = ""
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var bio: String?
    var url: String?
    var identifier: String?
    
    static var endpoint: String {
        return User.userKey
    }
    var dictionaryCopy: [String : AnyObject] {
        return [kUsername: username, kFirstName: firstName, kLastName: lastName, kEmail: email, kPassword: password, kBio: (bio)!, kURL: (url)!]
        }
        
    init(username: String, firstName: String, lastName: String, email: String, password: String, bio: String, URL: String, identifier: String) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.bio = bio
        self.url = URL
        self.identifier = identifier
    }
    
    init?(dictionary: [String: AnyObject], identifier: String) {
        guard let username = dictionary[kUsername] as? String, firstName = dictionary[kFirstName] as? String,
            lastName = dictionary[kLastName] as? String, email = dictionary[kEmail] as? String, password = dictionary[kPassword] as? String, bio = dictionary[kBio] as? String?, URL = dictionary[kURL] as? String?
            else { return nil }
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.bio = bio
        self.url = URL
        self.identifier = identifier
    }
}
