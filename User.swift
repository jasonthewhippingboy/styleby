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
    private let kBio = "bio"
    private let kURL = "url"
    private let kId = "identifier"
    
    var username = ""
    var firstName: String
    var lastName: String
    var email: String
    var bio: String?
    var url: String?
    var identifier: String?
    
    var endpoint: String {
        return User.userKey
    }
    var identifiedEndpoint: String {
        return "\(endpoint)/\(identifier)"
    }
    var dictionaryCopy: [String : AnyObject] {
        guard let identifier = identifier  else {
    return ["":""]
    
    }
        return [kUsername: username, kFirstName: firstName, kLastName: lastName, kEmail: email, kBio: (bio)!, kURL: (url)!,kId: (identifier)]
        }
        
    init(username: String, firstName: String, lastName: String, email: String, bio: String? = nil, URL: String? = nil, identifier: String? = nil) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.bio = bio
        self.url = URL
        self.identifier = identifier
    }
    
    init?(dictionary: [String: AnyObject], identifier: String) {
        guard let username = dictionary[kUsername] as? String, firstName = dictionary[kFirstName] as? String,
            lastName = dictionary[kLastName] as? String, email = dictionary[kEmail] as? String, bio = dictionary[kBio] as? String?, URL = dictionary[kURL] as? String?
            else { return nil }
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.bio = bio
        self.url = URL
        self.identifier = identifier
    }
}


extension User: Equatable { }

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.username == rhs.username && lhs.identifier == rhs.identifier
}
