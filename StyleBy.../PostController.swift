//
//  PostController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PostController {
    
    
    static func fetchStyleFeedForUser(user: User, completion: (posts: [Post]?) -> Void) {
        
        guard let currentUser = UserController.sharedController.currentUser else {
            completion(posts: nil)
            return
        }
        // Get posts only for current user
//        postsForUser(user) { (posts) in
//            completion(posts: posts)
//        }
        UserController.sharedController.followedByUser(user) { (followed) in
            
            var allPosts: [Post] = []
            let dispatchGroup = dispatch_group_create()
            
            
            dispatch_group_enter(dispatchGroup)
            postsForUser(currentUser, completion: { (posts) -> Void in
                
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
    
    static func addPost(image: UIImage, topBy: String?, bottomBy: String?, shoesBy: String?, accessoriesBy: String?, completion: (success: Bool, post: Post?) -> Void) {
        
        guard let currentUser = UserController.sharedController.currentUser else {
            completion(success: false, post: nil)
            return
        }
        var post = Post(topBy: topBy, bottomBy: bottomBy, shoesBy: shoesBy, accessoriesBy: accessoriesBy, username: currentUser.username)
        post.save()
        guard let postIdentifier = post.identifier else { completion(success: false, post: nil); return }
        
        ImageController.uploadImage(image, identifier: postIdentifier) { (success) -> Void in
            
            if success {
                completion(success: true, post: post)
            } else {
                completion(success: false, post: nil)
            }
        }
    }
    
    static func postFromIdentifier(identifier: String, completion: (post: Post?) -> Void) {
        
        FirebaseController.ref.child("posts/\(identifier)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            guard let userDictionary = snapshot.value as? [String: String] else {
                completion(post: nil)
                return
            }
            let post = Post(dictionary: userDictionary, identifier: identifier)
            completion(post: post)
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
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, post: nil)
                return
            }
            
            var comment = Comment(username: currentUser.username, text: text, postIdentifier: postIdentifier)
            comment.save()
            
            PostController.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
                completion(success: true, post: post)
            }
        } else {
            
            var post = post
            post.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, post: nil)
                return
            }
            var comment = Comment(username: currentUser.username, text: text, postIdentifier: post.identifier!)
            comment.save()
            
            PostController.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
                completion(success: true, post: post)
            }
        }
    }
    
    static func deleteComment(comment: Comment, completion: (success: Bool, post: Post?) -> Void) {
        comment.delete()
        
        PostController.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
            completion(success: true, post: post)
        }
    }
    
    static func addLikeToPost(post: Post, completion: (success: Bool, post: Post?) -> Void) {
        
        if let postIdentifier = post.identifier {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, post: nil)
                return
            }
            
            var like = Like(username: currentUser.username, postIdentifier: postIdentifier)
            like.save()
            
        } else {
            
            var post = post
            post.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, post: nil)
                return
            }
            var like = Like(username: currentUser.username, postIdentifier: post.identifier!)
            like.save()
        }
        
        PostController.postFromIdentifier(post.identifier!, completion: { (post) -> Void in
            completion(success: true, post: post)
        })
    }
    
    static func deleteLike(like: Like, completion: (success: Bool, post: Post?) -> Void) {
        
        like.delete()
        
        PostController.postFromIdentifier(like.postIdentifier) { (post) -> Void in
            completion(success: true, post: post)
        }
    }
    
    static func orderPosts(posts: [Post]) -> [Post] {
        
        return posts.sort({$0.0.identifier > $0.1.identifier})
    }
    
    //    static func mockPosts() -> [Post] {
    //
    //        let sampleImageIdentifier = "-K1l4125TYvKMc7rcp5e"
    //
    //        let like1 = Like(username: "gozer", postIdentifier: "1234")
    //        let like2 = Like(username: "louis", postIdentifier: "4566")
    //        let like3 = Like(username: "vinzclortho", postIdentifier: "43212")
    //
    //        let comment1 = Comment(username: "dana", text: "are you the keymaster?", postIdentifier: "1234")
    //        let comment2 = Comment(username: "gozer", text: "the choice has been made", postIdentifier: "4566")
    //
    //        let post1 = Post(imageEndpoint: sampleImageIdentifier, caption: "doe!", comments: [comment1, comment2], likes: [like1, like2, like3])
    //        let post2 = Post(imageEndpoint: sampleImageIdentifier, caption: "ray' kids!")
    //        let post3 = Post(imageEndpoint: sampleImageIdentifier, caption: "egon")
    //
    //        return [post1, post2, post3]
    //    }
    
    
}
