//
//  Post.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation

class Post: Equatable, FirebaseType {
    
    fileprivate let kUsername = "username"
    fileprivate let kImageEndpoint = "image"
    fileprivate let kTopBy = "top"
    fileprivate let kBottomBy = "bottom"
    fileprivate let kShoesBy = "shoes"
    fileprivate let kAccessoriesBy = "accessories"
    fileprivate let kComments = "comments"
    fileprivate let kLikes = "likes"
    fileprivate let kIdentifier = "identifier"
    
    let topBy: String?
    let bottomBy: String?
    let shoesBy: String?
    let accessoriesBy: String?
    let username: String
    let comments: [Comment]
    let likes: [Like]
    var identifier: String?
    var endpoint: String {
        return "posts"
    }
    
    var imageEndpoint: String {
        guard let identifier = identifier else { return "" }
        return "images/\(identifier)"
    }
    
    var dictionaryCopy: [String: AnyObject] {
        var dictionaryCopy: [String: AnyObject] = [kUsername : username as AnyObject, kComments : comments as AnyObject, kLikes : likes as AnyObject]
        
        if let topBy = topBy {
            dictionaryCopy.updateValue(topBy as AnyObject, forKey: kTopBy)
        }
        if let bottomBy = bottomBy {
            dictionaryCopy.updateValue(bottomBy as AnyObject, forKey: kBottomBy)
        }
        if let shoesBy = shoesBy {
            dictionaryCopy.updateValue(shoesBy as AnyObject, forKey: kShoesBy)
        }
        if let accessoriesBy = accessoriesBy {
            dictionaryCopy.updateValue(accessoriesBy as AnyObject, forKey: kAccessoriesBy)
        }
        return dictionaryCopy
    }
    
    init(topBy: String?, bottomBy: String?, shoesBy: String?, accessoriesBy: String?, username: String = "", comments: [Comment] = [], likes: [Like] = [], identifier: String? = nil) {
        
        self.topBy = topBy
        self.bottomBy = bottomBy
        self.shoesBy = shoesBy
        self.accessoriesBy = accessoriesBy
        self.username = username
        self.comments = comments
        self.likes = likes
    }
    
    required init?(dictionary json: [String : AnyObject], identifier: String) {
        guard let username = json[kUsername] as? String else { return nil }
        
        self.topBy = json[kTopBy] as? String
        self.bottomBy = json[kBottomBy] as? String
        self.shoesBy = json[kShoesBy] as? String
        self.accessoriesBy = json[kAccessoriesBy] as? String
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

func ==(lhs: Post, rhs: Post) -> Bool {
    
    return (lhs.username == rhs.username) && (lhs.identifier == rhs.identifier)
}
