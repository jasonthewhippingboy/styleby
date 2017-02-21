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


class Fashion911Controller {
    
    
    static func fetchStyleFeedForUser(_ user: User, completion: @escaping (_ fashion911: [Fashion911]?) -> Void) {
        
        UserController.sharedController.followedByUser(user) { (followed) in
            
            var allFashion911: [Fashion911] = []
            let dispatchGroup = DispatchGroup()
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(nil)
                return
            }
            
            dispatchGroup.enter()
            fashion911ForUser(currentUser, completion: { (fashion911) -> Void in
                
                if let fashion911 = fashion911 {
                    allFashion911 += fashion911
                }
                
                dispatchGroup.leave()
            })
            
            if let followed = followed {
                for user in followed {
                    
                    dispatchGroup.enter()
                    fashion911ForUser(user, completion: { (fashion911) in
                        if let fashion911 = fashion911 {
                            allFashion911 += fashion911
                        }
                        dispatchGroup.leave()
                    })
                }
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main, execute: { () -> Void in
                let orderedFashion911 = orderFashion911(allFashion911)
                completion(orderedFashion911)
            })
        }
    }
    
    static func addFashion911(_ image: UIImage, whatsYourEmergency: String?, completion: @escaping (_ success: Bool, _ fashion911: Fashion911?) -> Void) {
        
        guard let currentUser = UserController.sharedController.currentUser else {
            completion(false, nil)
            return
        }
        
        var fashion911 = Fashion911(whatsYourEmergency: whatsYourEmergency, username: currentUser.username)
        fashion911.save()
        
        guard let fashionIdentifier = fashion911.identifier else { completion(false, nil); return }
        
        ImageController.uploadImage(image, identifier: fashionIdentifier) { (success) -> Void in
            if success {
                completion(true,fashion911)
            } else {
                completion(false,nil)
            }
        }
    }
    
    static func fashion911FromIdentifier(_ identifier: String, completion: @escaping (_ fashion911: Fashion911?) -> Void) {
        
        FirebaseController.ref.child("fashion911\(identifier)").observeSingleEvent(of: .value, with: { snapshot in
            guard let userDictionary = snapshot.value as? [String: String] else {
                completion(nil)
                return
            }
            
            let fashion911 = Fashion911(dictionary: userDictionary as [String : AnyObject], identifier: identifier)
            completion(fashion911)
        })
    }
    
    static func fashion911ForUser(_ user: User, completion: @escaping (_ fashion911: [Fashion911]?) -> Void) {
        
        FirebaseController.ref.child("fashion911").queryOrdered(byChild: "username").queryEqual(toValue: user.username).observeSingleEvent(of: .value, with: { snapshot in
            
            
            if let fashion911Dictionaries = snapshot.value as? [String: AnyObject] {
                
                let fashion911 = fashion911Dictionaries.flatMap({Fashion911(dictionary: $0.1 as! [String : AnyObject], identifier: $0.0)})
                
                let orderedFashion911 = orderFashion911(fashion911)
                
                completion(orderedFashion911)
                
            } else {
                
                completion(nil)
            }
        })
        
    }
    
    static func deleteFashion911(_ fashion911: Fashion911) {
        fashion911.delete()
        
    }
    
    static func addFashion911CommentWithTextToFashion911(_ text: String, fashion911: Fashion911, completion: @escaping (_ success: Bool, _ fashion911: Fashion911?) -> Void?) {
        if let fashion911Identifier = fashion911.identifier {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(false, nil)
                return
            }
            
            var fashion911comment = Fashion911Comment(username: currentUser.username, text: text, fashion911Identifier: fashion911Identifier)
            fashion911comment.save()
            
            Fashion911Controller.fashion911FromIdentifier(fashion911comment.fashion911Identifier) { (fashion911) -> Void in
                completion(true, fashion911)
            }
        } else {
            
            var fashion911 = fashion911
            fashion911.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(false, nil)
                return
            }
            var fashion911Comment = Fashion911Comment(username: currentUser.username, text: text, fashion911Identifier: fashion911.identifier!)
            fashion911Comment.save()
            
            Fashion911Controller.fashion911FromIdentifier(fashion911Comment.fashion911Identifier) { (fashion911) -> Void in
                completion(true, fashion911)
            }
        }
    }
    
    static func deleteFashion911Comment(_ fashion911comment: Fashion911Comment, completion: @escaping (_ success: Bool, _ fashion911: Fashion911?) -> Void) {
        fashion911comment.delete()
        
        Fashion911Controller.fashion911FromIdentifier(fashion911comment.fashion911Identifier) { (fashion911) -> Void in
            completion(true, fashion911)
        }
    }
    
    static func addFashion911LikeToFashion911(_ fashion911: Fashion911, completion: @escaping (_ success: Bool, _ fashion911: Fashion911?) -> Void) {
        
        if let fashion911Identifier = fashion911.identifier {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(false, nil)
                return
            }
            
            var fashion911Like = Fashion911Like(username: currentUser.username, postIdentifier: fashion911Identifier)
            fashion911Like.save()
            
        } else {
            
            var fashion911 = fashion911
            fashion911.save()
            
            guard let currentUser = UserController.sharedController.currentUser else {
                completion(false, nil)
                return
            }
            var fashion911Like = Fashion911Like(username: currentUser.username, postIdentifier: fashion911.identifier!)
            fashion911Like.save()
        }
        
        Fashion911Controller.fashion911FromIdentifier(fashion911.identifier!, completion: { (fashion911) -> Void in
            completion(true, fashion911)
        })
    }
    
    static func deleteLike(_ fashion911Like: Fashion911Like, completion: @escaping (_ success: Bool, _ fashion911: Fashion911?) -> Void) {
        
        fashion911Like.delete()
        
        Fashion911Controller.fashion911FromIdentifier(fashion911Like.postIdentifier) { (fashion911) -> Void in
            completion(true, fashion911)
        }
    }
    
    static func orderFashion911(_ fashion911: [Fashion911]) -> [Fashion911] {
        
        return fashion911.sorted(by: {$0.0.identifier > $0.1.identifier})
    }
    
}
