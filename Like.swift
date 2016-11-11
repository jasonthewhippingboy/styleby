//
//  Like.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation

struct Like: FirebaseType {
    
    private let kPost = "post"
    private let kUsername = "username"
    
    let username: String
    let postIdentifier: String
    var identifier: String?
    var endpoint: String {
        return "/posts/\(self.postIdentifier)/likes/"
    }
    var dictionaryCopy: [String : AnyObject] {
        return [kUsername: username, kPost: postIdentifier]
    }
    
    init?(dictionary: [String : AnyObject], identifier: String) {
        guard let postIdentifier = dictionary[kPost] as? String,
            let username = dictionary[kUsername] as? String else { return nil }
        
        self.postIdentifier = postIdentifier
        self.username = username
        self.identifier = identifier
    }
    
    init(username: String, postIdentifier: String, identifier: String? = nil) {
        
        self.username = username
        self.postIdentifier = postIdentifier
        self.identifier = identifier
    }
}

func ==(lhs: Like, rhs: Like) -> Bool {
    
    return (lhs.username == rhs.username) && (lhs.identifier == rhs.identifier)
}
