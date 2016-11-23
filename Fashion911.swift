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
    private let kWhatsYourEmergency = "whatsYourEmergency"
    private let kFashion911Comment = "fashion911comment"
    private let kLikes = "likes"
    private let kIdentifier = "identifier"
    
    let whatsYourEmergency: String?
    let username: String
    let fashion911comment: [Fashion911Comment]
    let likes: [Like]
    var identifier: String?
    var endpoint: String {
        return "fashion911"
    }
    
    var imageEndpoint: String {
        guard let identifier = identifier else { return "" }
        return "images/\(identifier)"
    }
    var dictionaryCopy: [String : AnyObject] {
        var dictionaryCopy: [String: AnyObject] = [kUsername : username, kImageEndpoint : imageEndpoint, kFashion911Comment : fashion911comment.map { $0.dictionaryCopy }, kLikes : likes.map { $0.dictionaryCopy }]
        
        if let whatsYourEmergency = whatsYourEmergency {
            dictionaryCopy.updateValue(whatsYourEmergency, forKey: kWhatsYourEmergency)
        }
        
        return dictionaryCopy
    }
    
    init(whatsYourEmergency: String?, username: String = "", fashion911comment: [Fashion911Comment] = [], likes: [Like] = [], identifier: String? = nil) {
        
        self.whatsYourEmergency = kWhatsYourEmergency
        self.username = username
        self.fashion911comment = fashion911comment
        self.likes = likes
    }
    
    init?(dictionary json: [String : AnyObject], identifier: String) {
        guard let username = json[kUsername] as? String else { return nil }
        
        self.whatsYourEmergency = json[kWhatsYourEmergency] as? String
        self.username = username
        self.identifier = identifier
        
        if let fashion911commentDictionaries = json[kFashion911Comment] as? [String: AnyObject] {
            self.fashion911comment = fashion911commentDictionaries.flatMap({Fashion911Comment(dictionary: $0.1 as! [String : AnyObject], identifier: $0.0)})
        } else {
            self.fashion911comment = []
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