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
    
    
    static func fetchTimelineForUser(user: User, completion: (fashion911: [Fashion911]?) -> Void) {
        
        UserController.sharedController.followedByUser(user) { (followed) in
            
            var allFashion911: [Fashion911] = []
            let dispatchGroup = dispatch_group_create()
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(fashion911: nil)
                return
            }
            
            dispatch_group_enter(dispatchGroup)
            fashion911ForUser(currentUser, completion: { (fashion911) -> Void in
                
                if let fashion911 = fashion911 {
                    allFashion911 += fashion911
                }
                
                dispatch_group_leave(dispatchGroup)
            })
            
            if let followed = followed {
                for user in followed {
                    
                    dispatch_group_enter(dispatchGroup)
                    fashion911ForUser(user, completion: { (fashion911) in
                        if let fashion911 = fashion911 {
                            allFashion911 += fashion911
                        }
                        dispatch_group_leave(dispatchGroup)
                    })
                }
            }
            
            dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), { () -> Void in
                let orderedFashion911 = orderFashion911(allFashion911)
                completion(fashion911: orderedFashion911)
            })
        }
    }
    
    static func addFashion911(image: UIImage, whatsYourEmergency: String?, completion: (success: Bool, fashion911: Fashion911?) -> Void) {
        
        guard let currentUser = UserController.sharedController.currentUser else {
            completion(success: false, fashion911: nil)
            return
        }
        
        var fashion911 = Fashion911(whatsYourEmergency: whatsYourEmergency, username: currentUser.username)
        fashion911.save()
        
        guard let fashionIdentifier = fashion911.identifier else { completion(success: false, fashion911: nil); return }
        
        ImageController.uploadImage(image, identifier: fashionIdentifier) { (success) -> Void in
            if success {
                completion(success: true, fashion911: fashion911)
            } else {
                completion(success: false, fashion911: nil)
            }
        }
    }
    
    static func fashion911FromIdentifier(identifier: String, completion: (fashion911: Fashion911?) -> Void) {
        
        FirebaseController.ref.child("fashion911\(identifier)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            guard let userDictionary = snapshot.value as? [String: String] else {
                completion(fashion911: nil)
                return
            }
            
            let fashion911 = Fashion911(dictionary: userDictionary, identifier: identifier)
            completion(fashion911: fashion911)
        })
    }
    
    static func fashion911ForUser(user: User, completion: (fashion911: [Fashion911]?) -> Void) {
        
        FirebaseController.ref.child("fashion911").queryOrderedByChild("username").queryEqualToValue(user.username).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            
            if let fashion911Dictionaries = snapshot.value as? [String: AnyObject] {
                
                let fashion911 = fashion911Dictionaries.flatMap({Fashion911(dictionary: $0.1 as! [String : AnyObject], identifier: $0.0)})
                
                let orderedFashion911 = orderFashion911(fashion911)
                
                completion(fashion911: orderedFashion911)
                
            } else {
                
                completion(fashion911: nil)
            }
        })
        
    }
    
    static func deleteFashion911(fashion911: Fashion911) {
        fashion911.delete()
        
    }
    
    static func addCommentWithTextToFashion911(text: String, fashion911: Fashion911, completion: (success: Bool, fashion911: Fashion911?) -> Void?) {
        if let fashion911Identifier = fashion911.identifier {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, fashion911: nil)
                return
            }
            
            var comment = Comment(username: currentUser.username, text: text, fashion911: fashion911Identifier)
            comment.save()
            
            Fashion911Controller.fashion911FromIdentifier(comment.fashion911Identifier) { (fashion911) -> Void in
                completion(success: true, fashion911: fashion911)
            }
        } else {
            
            var fashion911 = fashion911
            fashion911.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, fashion911: nil)
                return
            }
            var Comment = Comment(username: currentUser.username, text: text, fashion911Identifier: fashion911.identifier!)
            comment.save()
            
            Fashion911Controller.fashion911FromIdentifier(comment.fashion911Identifier) { (fashion911) -> Void in
                completion(success: true, fashion911: fashion911)
            }
        }
    }
    
    static func deleteComment(comment: Comment, completion: (success: Bool, fashion911: Fashion911?) -> Void) {
        comment.delete()
        
        Fashion911Controller.fashion911FromIdentifier(comment.fashion911Identifier) { (fashion911) -> Void in
            completion(success: true, fashion911: fashion911)
        }
    }
    
    static func addLikeToFashion911(fashion911: Fashion911, completion: (success: Bool, fashion911: Fashion911?) -> Void) {
        
        if let fashion911Identifier = fashion911.identifier {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, fashion911: nil)
                return
            }
            
            var like = Like(username: currentUser.username, fashion911Identifier: fashion911Identifier)
            like.save()
            
        } else {
            
            var fashion911 = fashion911
            fashion911.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, fashion911: nil)
                return
            }
            var like = Like(username: currentUser.username, fashion911Identifier: fashion911.identifier!)
            like.save()
        }
        
        Fashion911Controller.fashion911FromIdentifier(fashion911.identifier!, completion: { (fashion911) -> Void in
            completion(success: true, fashion911: fashion911)
        })
    }
    
    static func deleteLike(like: Like, completion: (success: Bool, fashion911: Fashion911?) -> Void) {
        
        like.delete()
        
        Fashion911Controller.fashion911FromIdentifier(like.fashion911Identifier) { (fashion911) -> Void in
            completion(success: true, fashion911: fashion911)
        }
    }
    
    static func orderFashion911(fashion911: [Fashion911]) -> [Fashion911] {
        
        return fashion911.sort({$0.0.identifier > $0.1.identifier})
    }
    
}