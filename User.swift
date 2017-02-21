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
    fileprivate let kUsername = "username"
    fileprivate let kFirstName = "firstName"
    fileprivate let kLastName = "lastName"
    fileprivate let kEmail = "email"
    fileprivate let kBio = "bio"
    fileprivate let kURL = "url"
    fileprivate let kId = "identifier"
    
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
        return "\(endpoint)/\(identifier!)"
    }
    var dictionaryCopy: [String : AnyObject] {
        guard let identifier = identifier  else {
    return ["":"" as AnyObject]
    
    }
        return [kUsername: username as AnyObject, kFirstName: firstName as AnyObject, kLastName: lastName as AnyObject, kEmail: email as AnyObject, kBio: (bio)! as AnyObject, kURL: (url)! as AnyObject,kId: (identifier as AnyObject)]
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
        guard let username = dictionary[kUsername] as? String, let firstName = dictionary[kFirstName] as? String,
            let lastName = dictionary[kLastName] as? String, let email = dictionary[kEmail] as? String, let bio = dictionary[kBio] as? String?, let URL = dictionary[kURL] as? String?
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
