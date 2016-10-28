//
//  Post.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation

struct Post: Equatable, FirebaseType {
    
    private let kUsername = "username"
    private let kImageEndpoint = "image"
    private let kTopBy = "top"
    private let kBottomBy = "bottom"
    private let kShoesBy = "shoes"
    private let kAccessoriesBy = "accessories"
    private let kComments = "comments"
    private let kLikes = "likes"
    
    let imageEndpoint: String
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
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kUsername : username, kImageEndpoint : imageEndpoint, kComments : comments.map({$0.jsonValue}), kLikes : likes.map({$0.jsonValue})]
        
        if let topBy = topBy {
            json.updateValue(topBy, forKey: kTopBy)
        }
        if let bottomBy = bottomBy {
            json.updateValue(bottomBy, forKey: kBottomBy)
        }
        if let shoesBy = shoesBy {
            json.updateValue(shoesBy, forKey: kShoesBy)
        }
        if let topBy = accessoriesBy {
            json.updateValue(accessoriesBy, forKey: kAccessoriesBy)
        }
        return json
    }
    
    init(imageEndpoint: String, topBy: String?, bottomBy: String?, shoesBy: String?, accessoriesBy: String?, username: String = "", comments: [Comment] = [], likes: [Like] = [], identifier: String? = nil) {
        
        self.imageEndpoint = imageEndpoint
        self.topBy = topBy
        self.bottomBy = bottomBy
        self.shoesBy = shoesBy
        self.accessoriesBy = accessoriesBy
        self.username = username
        self.comments = comments
        self.likes = likes
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let imageEndpoint = json[kImageEndpoint] as? String,
            let username = json[kUsername] as? String else { return nil }
        
        self.imageEndpoint = imageEndpoint
        self.topBy = json[kTopBy] as? String
        self.bottomBy = json[kBottomBy] as? String
        self.shoesBy = json[kShoesBy] as? String
        self.accessoriesBy = json[kAccessoriesBy] as? String
        self.username = username
        self.identifier = identifier
        
        if let commentDictionaries = json[kComments] as? [String: AnyObject] {
            self.comments = commentDictionaries.flatMap({Comment(json: $0.1 as! [String : AnyObject], identifier: $0.0)})
        } else {
            self.comments = []
        }
        
        if let likeDictionaries = json[kLikes] as? [String: AnyObject] {
            self.likes = likeDictionaries.flatMap({Like(json: $0.1 as! [String : AnyObject], identifier: $0.0)})
        } else {
            self.likes = []
        }
        
    }
    
}

func ==(lhs: Post, rhs: Post) -> Bool {
    
    return (lhs.username == rhs.username) && (lhs.identifier == rhs.identifier)
}
