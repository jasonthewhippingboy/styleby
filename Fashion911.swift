//
//  Fashion911.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/29/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation

struct Fashion911: Equatable, FirebaseType {
    
    private let kUsername = "username"
    private let kImageEndpoint = "image"
    private let kwhatsYourEmergency = "whatsYourEmergency"
    private let kComments = "comments"
    private let kLikes = "likes"
    
    let imageEndpoint: String
    let whatsYourEmergency: String?
    let username: String
    let comments: [Comment]
    let likes: [Like]
    var identifier: String?
    var endpoint: String {
        return "posts"
    }
    var dictionaryCopy: [String : AnyObject] {
        var dictionaryCopy: [String: AnyObject] = [kUsername : username, kImageEndpoint : imageEndpoint, kComments : comments.map { $0.dictionaryCopy }, kLikes : likes.map { $0.dictionaryCopy }]
        
        if let whatsYourEmergency = whatsYourEmergency {
            dictionaryCopy.updateValue(whatsYourEmergency, forKey: kwhatsYourEmergency)
        }
        
        return dictionaryCopy
    }
    
    init(imageEndpoint: String, whatsYourEmergency: String?, username: String = "", comments: [Comment] = [], likes: [Like] = [], identifier: String? = nil) {
        
        self.imageEndpoint = imageEndpoint
        self.whatsYourEmergency = kwhatsYourEmergency
        self.username = username
        self.comments = comments
        self.likes = likes
    }
    
    init?(dictionary json: [String : AnyObject], identifier: String) {
        guard let imageEndpoint = json[kImageEndpoint] as? String,
            let username = json[kUsername] as? String else { return nil }
        
        self.imageEndpoint = imageEndpoint
        self.whatsYourEmergency = json[kwhatsYourEmergency] as? String
        self.username = username
        self.identifier = identifier
        
        if let commentDictionaries = json[kComments] as? [String: AnyObject] {
            self.comments = commentDictionaries.flatMap({Comment(dictionary: $0.1 as! [String : AnyObject], identifier: $0.0)})
        } else {
            self.comments = []
        }
        
        if let likeDictionaries = json[kLikes] as? [String: AnyObject] {
            self.likes = likeDictionaries.flatMap({Like(dictionary: $0.1 as! [String : AnyObject], identifier: $0.0)})
        } else {
            self.likes = []
        }
        
    }
    
}

func ==(lhs: Fashion911, rhs: Fashion911) -> Bool {
    
    return (lhs.username == rhs.username) && (lhs.identifier == rhs.identifier)
}