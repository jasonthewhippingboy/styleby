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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PostController {
    
    
    static func fetchStyleFeedForUser(_ user: User, completion: @escaping (_ posts: [Post]?) -> Void) {
        
        guard let currentUser = UserController.sharedController.currentUser else {
            completion(nil)
            return
        }
        // Get posts only for current user
//        postsForUser(user) { (posts) in
//            completion(posts: posts)
//        }
        UserController.sharedController.followedByUser(user) { (followed) in
            
            var allPosts: [Post] = []
            let dispatchGroup = DispatchGroup()
            
            
            dispatchGroup.enter()
            postsForUser(currentUser, completion: { (posts) -> Void in
                
                if let posts = posts {
                    allPosts += posts
                }
                
                dispatchGroup.leave()
            })
            
            if let followed = followed {
                for user in followed {
                    
                    dispatchGroup.enter()
                    postsForUser(user, completion: { (posts) in
                        if let posts = posts {
                            allPosts += posts
                        }
                        dispatchGroup.leave()
                    })
                }
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main, execute: { () -> Void in
                let orderedPosts = orderPosts(allPosts)
                completion(orderedPosts)
            })
        }
    }
    
    static func addPost(_ image: UIImage, topBy: String?, bottomBy: String?, shoesBy: String?, accessoriesBy: String?, completion: @escaping (_ success: Bool, _ post: Post?) -> Void) {
        
        guard let currentUser = UserController.sharedController.currentUser else {
            completion(false, nil)
            return
        }
        var post = Post(topBy: topBy, bottomBy: bottomBy, shoesBy: shoesBy, accessoriesBy: accessoriesBy, username: currentUser.username)
        post.save()
        guard let postIdentifier = post.identifier else { completion(false, nil); return }
        
        ImageController.uploadImage(image, identifier: postIdentifier) { (success) -> Void in
            
            if success {
                completion(true,post)
            } else {
                completion(false,nil)
            }
        }
    }
    
    static func postFromIdentifier(_ identifier: String, completion: @escaping (_ post: Post?) -> Void) {
        
        FirebaseController.ref.child("posts/\(identifier)").observeSingleEvent(of: .value, with: { snapshot in
            guard let userDictionary = snapshot.value as? [String: String] else {
                completion(nil)
                return
            }
            let post = Post(dictionary: userDictionary as [String : AnyObject], identifier: identifier)
            completion(post)
        })
    }
    
    static func postsForUser(_ user: User, completion: @escaping (_ posts: [Post]?) -> Void) {
        
        FirebaseController.ref.child("posts").queryOrdered(byChild: "username").queryEqual(toValue: user.username).observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let postDictionaries = snapshot.value as? [String: AnyObject] {
                
                let posts = postDictionaries.flatMap({Post(dictionary: $0.1 as! [String : AnyObject], identifier: $0.0)})
                
                let orderedPosts = orderPosts(posts)
                
                completion(orderedPosts)
                
            } else {
                
                completion(nil)
            }
        })
        
    }
    
    static func deletePost(_ post: Post) {
        post.delete()
        
    }
    
    static func addCommentWithTextToPost(_ text: String, post: Post, completion: @escaping (_ success: Bool, _ post: Post?) -> Void?) {
        if let postIdentifier = post.identifier {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(false, nil)
                return
            }
            
            var comment = Comment(username: currentUser.username, text: text, postIdentifier: postIdentifier)
            comment.save()
            
            PostController.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
                completion(true, post)
            }
        } else {
            
            var post = post
            post.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(false, nil)
                return
            }
            var comment = Comment(username: currentUser.username, text: text, postIdentifier: post.identifier!)
            comment.save()
            
            PostController.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
                completion(true, post)
            }
        }
    }
    
    static func deleteComment(_ comment: Comment, completion: @escaping (_ success: Bool, _ post: Post?) -> Void) {
        comment.delete()
        
        PostController.postFromIdentifier(comment.postIdentifier) { (post) -> Void in
            completion(true, post)
        }
    }
    
    static func addLikeToPost(_ post: Post, completion: @escaping (_ success: Bool, _ post: Post?) -> Void) {
        
        if let postIdentifier = post.identifier {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(false, nil)
                return
            }
            
            var like = Like(username: currentUser.username, postIdentifier: postIdentifier)
            like.save()
            
        } else {
            
            var post = post
            post.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(false, nil)
                return
            }
            var like = Like(username: currentUser.username, postIdentifier: post.identifier!)
            like.save()
        }
        
        PostController.postFromIdentifier(post.identifier!, completion: { (post) -> Void in
            completion(true, post)
        })
    }
    
    static func deleteLike(_ like: Like, completion: @escaping (_ success: Bool, _ post: Post?) -> Void) {
        
        like.delete()
        
        PostController.postFromIdentifier(like.postIdentifier) { (post) -> Void in
            completion(true, post)
        }
    }
    
    static func orderPosts(_ posts: [Post]) -> [Post] {
        
        return posts.sorted(by: {$0.0.identifier > $0.1.identifier})
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
