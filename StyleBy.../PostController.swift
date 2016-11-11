//
//  PostController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    
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
    
    static func addPost(image: UIImage, topBy: String?, bottomBy: String?, shoesBy: String?, accessoriesBy: String?, completion: (success: Bool, post: Post?) -> Void) {
        
        ImageController.uploadImage(image) { (identifier) -> Void in
            
            if let identifier = identifier {
                var post = Post(imageEndpoint: identifier, topBy: topBy, bottomBy: bottomBy, shoesBy: shoesBy, accessoriesBy: accessoriesBy, username: UserController.sharedController.currentUser.username)
                post.save()
                completion(success: true, post: post)
            } else {
                completion(success: false, post: nil)
            }
        }
    }
    
    static func postFromIdentifier(identifier: String, completion: (post: Post?) -> Void) {
        
        FirebaseController.ref.child("posts/\(identifier)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            // TODO: Parse post data
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
            
            PostController.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
                completion(success: true, post: post)
            }
        } else {
            
            var post = post
            post.save()
            var comment = Comment(username: UserController.sharedController.currentUser.username, text: text, postIdentifier: post.identifier!)
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
            
            var like = Like(username: UserController.sharedController.currentUser.username, postIdentifier: postIdentifier)
            like.save()
            
        } else {
            
            var post = post
            post.save()
            var like = Like(username: UserController.sharedController.currentUser.username, postIdentifier: post.identifier!)
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
