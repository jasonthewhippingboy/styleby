//
//  Fashion911.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/29/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation

struct Fashion911: Equatable, FirebaseType {
    
    fileprivate let kUsername = "username"
    fileprivate let kImageEndpoint = "image"
    fileprivate let kWhatsYourEmergency = "whatsYourEmergency"
    fileprivate let kFashion911Comment = "fashion911comment"
    fileprivate let kFashion911Like = "fashion911like"
    fileprivate let kIdentifier = "identifier"
    
    let whatsYourEmergency: String?
    let username: String
    let fashion911comment: [Fashion911Comment]
    let fashion911like: [Fashion911Like]
    var identifier: String?
    var endpoint: String {
        return "fashion911"
    }
    
    var imageEndpoint: String {
        guard let identifier = identifier else { return "" }
        return "images/\(identifier)"
    }
    var dictionaryCopy: [String : AnyObject] {
        var dictionaryCopy: [String: AnyObject] = [kUsername : username as AnyObject, kImageEndpoint : imageEndpoint as AnyObject, kFashion911Comment : fashion911comment as AnyObject,kFashion911Like : fashion911like as AnyObject]
        
        if let whatsYourEmergency = whatsYourEmergency {
            dictionaryCopy.updateValue(whatsYourEmergency as AnyObject, forKey: kWhatsYourEmergency)
        }
        
        return dictionaryCopy
    }
    
    init(whatsYourEmergency: String?, username: String = "", fashion911comment: [Fashion911Comment] = [], fashion911like: [Fashion911Like] = [], identifier: String? = nil) {
        
        self.whatsYourEmergency = kWhatsYourEmergency
        self.username = username
        self.fashion911comment = fashion911comment
        self.fashion911like = fashion911like
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
        
        if let fashion911likeDictionaries = json[kFashion911Like] as? [String: AnyObject] {
            self.fashion911like = fashion911likeDictionaries.flatMap({Fashion911Like(dictionary: $0.1 as! [String : AnyObject], identifier: $0.0)})
        } else {
            self.fashion911like = []
        }
        
    }
    
}

func ==(lhs: Fashion911, rhs: Fashion911) -> Bool {
    
    return (lhs.username == rhs.username) && (lhs.identifier == rhs.identifier)
}
