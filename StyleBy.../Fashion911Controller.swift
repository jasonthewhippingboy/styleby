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
    
    static func addFashion911CommentWithTextToFashion911(text: String, fashion911: Fashion911, completion: (success: Bool, fashion911: Fashion911?) -> Void?) {
        if let fashion911Identifier = fashion911.identifier {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, fashion911: nil)
                return
            }
            
            var fashion911comment = Fashion911Comment(username: currentUser.username, text: text, fashion911Identifier: fashion911Identifier)
            fashion911comment.save()
            
            Fashion911Controller.fashion911FromIdentifier(fashion911comment.fashion911Identifier) { (fashion911) -> Void in
                completion(success: true, fashion911: fashion911)
            }
        } else {
            
            var fashion911 = fashion911
            fashion911.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, fashion911: nil)
                return
            }
            var fashion911Comment = Fashion911Comment(username: currentUser.username, text: text, fashion911Identifier: fashion911.identifier!)
            fashion911Comment.save()
            
            Fashion911Controller.fashion911FromIdentifier(fashion911Comment.fashion911Identifier) { (fashion911) -> Void in
                completion(success: true, fashion911: fashion911)
            }
        }
    }
    
    static func deleteFashion911Comment(fashion911comment: Fashion911Comment, completion: (success: Bool, fashion911: Fashion911?) -> Void) {
        fashion911comment.delete()
        
        Fashion911Controller.fashion911FromIdentifier(fashion911comment.fashion911Identifier) { (fashion911) -> Void in
            completion(success: true, fashion911: fashion911)
        }
    }
    
    static func addFashion911LikeToFashion911(fashion911: Fashion911, completion: (success: Bool, fashion911: Fashion911?) -> Void) {
        
        if let fashion911Identifier = fashion911.identifier {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, fashion911: nil)
                return
            }
            
            var fashion911Like = Fashion911Like(username: currentUser.username, postIdentifier: fashion911Identifier)
            fashion911Like.save()
            
        } else {
            
            var fashion911 = fashion911
            fashion911.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(success: false, fashion911: nil)
                return
            }
            var fashion911Like = Fashion911Like(username: currentUser.username, postIdentifier: fashion911.identifier!)
            fashion911Like.save()
        }
        
        Fashion911Controller.fashion911FromIdentifier(fashion911.identifier!, completion: { (fashion911) -> Void in
            completion(success: true, fashion911: fashion911)
        })
    }
    
    static func deleteLike(fashion911Like: Fashion911Like, completion: (success: Bool, fashion911: Fashion911?) -> Void) {
        
        fashion911Like.delete()
        
        Fashion911Controller.fashion911FromIdentifier(fashion911Like.postIdentifier) { (fashion911) -> Void in
            completion(success: true, fashion911: fashion911)
        }
    }
    
    static func orderFashion911(fashion911: [Fashion911]) -> [Fashion911] {
        
        return fashion911.sort({$0.0.identifier > $0.1.identifier})
    }
    
}