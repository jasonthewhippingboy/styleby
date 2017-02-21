//
//  Fashion911Comment.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 11/22/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation

struct Fashion911Comment: Equatable, FirebaseType {
    
    fileprivate let kFashion911 = "fashion911"
    fileprivate let kUsername = "username"
    fileprivate let kText = "text"
    
    let username: String
    let text: String
    let fashion911Identifier: String
    var identifier: String?
    var endpoint: String {
        return "/fashion911/\(fashion911Identifier)/comments/"
    }
    var dictionaryCopy: [String : AnyObject] {
        return [kFashion911 : fashion911Identifier as AnyObject, kUsername : username as AnyObject, kText : text as AnyObject]
    }
    
    init(username: String, text: String, fashion911Identifier: String, identifier: String? = nil) {
        
        self.username = username
        self.text = text
        self.fashion911Identifier = fashion911Identifier
        self.identifier = identifier
    }
    
    init?(dictionary json: [String : AnyObject], identifier: String) {
        guard let fashion911Identifier = json[kFashion911] as? String,
            let username = json[kUsername] as? String,
            let text = json[kText] as? String else { return nil }
        
        self.fashion911Identifier = fashion911Identifier
        self.username = username
        self.text = text
        self.identifier = identifier
    }
    
    
}

func ==(lhs: Fashion911Comment, rhs: Fashion911Comment) -> Bool {
    
    return (lhs.username == rhs.username) && (lhs.identifier == rhs.identifier)
}
