//
//  Fashion911lLike.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 11/29/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation


struct Fashion911Like: FirebaseType {
    
    fileprivate let kPost = "post"
    fileprivate let kUsername = "username"
    
    let username: String
    let postIdentifier: String
    var identifier: String?
    var endpoint: String {
        return "/posts/\(self.postIdentifier)/fashion911likes/"
    }
    var dictionaryCopy: [String : AnyObject] {
        return [kUsername: username as AnyObject, kPost: postIdentifier as AnyObject]
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

func ==(lhs: Fashion911Like, rhs: Fashion911Like) -> Bool {
    
    return (lhs.username == rhs.username) && (lhs.identifier == rhs.identifier)
}
