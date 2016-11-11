//
//  File.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation

struct Comment: Equatable, FirebaseType {
    
    private let kPost = "post"
    private let kUsername = "username"
    private let kText = "text"
    
    let username: String
    let text: String
    let postIdentifier: String
    var identifier: String?
    var endpoint: String {
        return "/posts/\(postIdentifier)/comments/"
    }
    var dictionaryCopy: [String : AnyObject] {
        return [kPost : postIdentifier, kUsername : username, kText : text]
    }
    
    init(username: String, text: String, postIdentifier: String, identifier: String? = nil) {
        
        self.username = username
        self.text = text
        self.postIdentifier = postIdentifier
        self.identifier = identifier
    }
    
    init?(dictionary json: [String : AnyObject], identifier: String) {
        guard let postIdentifier = json[kPost] as? String,
            let username = json[kUsername] as? String,
            let text = json[kText] as? String else { return nil }
        
        self.postIdentifier = postIdentifier
        self.username = username
        self.text = text
        self.identifier = identifier
    }
    
}

func ==(lhs: Comment, rhs: Comment) -> Bool {
    
    return (lhs.username == rhs.username) && (lhs.identifier == rhs.identifier)
}
