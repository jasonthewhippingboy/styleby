//
//  Fashion911Controller.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/29/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation
import Firebase

import UIKit

class Fashion911Controller {
    
    
    static func fetchTimelineForUser(user: User, completion: (posts: [Post]?) -> Void) {
        
        UserController.followedByUser(user) { (followed) in
            
            var allPosts: [Post] = []
            let dispatchGroup = dispatch_group_create()
            
            dispatch_group_enter(dispatchGroup)
            postsForUser(UserController.sharedController.currentUser, completion: { (posts) -> Void in
                
                if let posts = posts {
                    allPosts += posts
                }
                
                dispatch_group_leave(dispatchGroup)
            })
            
            if let followed = followed {
                for user in followed {
                    
                    dispatch_group_enter(dispatchGroup)
                    postsForUser(user, completion: { (posts) in
                        if let posts = posts {
                            allPosts += posts
                        }
                        dispatch_group_leave(dispatchGroup)
                    })
                }
            }
            
            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), { () -> Void in
                let orderedPosts = orderPosts(allPosts)
                completion(posts: orderedPosts)
            })
        }
    }
    
    static func addFashion911(image: UIImage, whatsYourEmergency: String?, completion: (success: Bool, fashion911: Fashion911?) -> Void) {
        
        ImageController.uploadImage(image) { (identifier) -> Void in
            
            if let identifier = identifier {
                var fashion911 = Fashion911(imageEndpoint: identifier, whatsYourEmergency: whatsYourEmergency, username: UserController.sharedController.currentUser.username)
                fashion911.save()
                completion(success: true, fashion911: fashion911)
            } else {
                completion(success: false, fashion911: nil)
            }
        }
    }
    
    static func postFromIdentifier(identifier: String, completion: (post: Post?) -> Void) {
        
        FirebaseController.ref.child("posts\(identifier)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            // TODO: Parse snapshot as Post
//            if let data = data as? [String: AnyObject] {
//                let post = Post(json: data, identifier: identifier)
//                
//                completion(post: post)
//            } else {
//                completion(post: nil)
//            }
        })
    }
    
    static func postsForUser(user: User, completion: (posts: [Post]?) -> Void) {
        
        FirebaseController.ref.child("posts").queryOrderedByChild("username").queryEqualToValue(user.username).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            
            if let postDictionaries = snapshot.value as? [String: AnyObject] {
                
                let posts = postDictionaries.flatMap({Post(dictionary: $0.1 as! [String : AnyObject], identifier: $0.0)})
                
                let orderedPosts = orderPosts(posts)
                
                completion(posts: orderedPosts)
                
            } else {
                
                completion(posts: nil)
            }
        })
        
    }
    
    static func deletePost(post: Post) {
        post.delete()
        
    }
    
    static func addCommentWithTextToPost(text: String, post: Post, completion: (success: Bool, post: Post?) -> Void?) {
        if let postIdentifier = post.identifier {
            
            var comment = Comment(username: UserController.sharedController.currentUser.username, text: text, postIdentifier: postIdentifier)
            comment.save()
            
            Fashion911Controller.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
                completion(success: true, post: post)
            }
        } else {
            
            var post = post
            post.save()
            var comment = Comment(username: UserController.sharedController.currentUser.username, text: text, postIdentifier: post.identifier!)
            comment.save()
            
            Fashion911Controller.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
                completion(success: true, post: post)
            }
        }
    }
    
    static func deleteComment(comment: Comment, completion: (success: Bool, post: Post?) -> Void) {
        comment.delete()
        
        Fashion911Controller.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
            completion(success: true, post: post)
        }
    }
    
    static func addLikeToPost(post: Post, completion: (success: Bool, post: Post?) -> Void) {
        
        if let postIdentifier = post.identifier {
            
            var like = Like(username: UserController.sharedController.currentUser.username, postIdentifier: postIdentifier)
            like.save()
            
        } else {
            
            var post = post
            post.save()
            var like = Like(username: UserController.sharedController.currentUser.username, postIdentifier: post.identifier!)
            like.save()
        }
        
        Fashion911Controller.postFromIdentifier(post.identifier!, completion: { (post) -> Void in
            completion(success: true, post: post)
        })
    }
    
    static func deleteLike(like: Like, completion: (success: Bool, post: Post?) -> Void) {
        
        like.delete()
        
        Fashion911Controller.postFromIdentifier(like.postIdentifier) { (post) -> Void in
            completion(success: true, post: post)
        }
    }
    
    static func orderPosts(posts: [Post]) -> [Post] {
        
        return posts.sort({$0.0.identifier > $0.1.identifier})
}

}