//
//  UserController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation
import Firebase

class UserController {
    
    private let kUser = "userKey"
    
    var currentUser: User! {
        get {
            guard let userDictionary = NSUserDefaults.standardUserDefaults().valueForKey(kUser) as? [String: AnyObject] else {
                    
                    return nil
            }
            // TODO: Actually get identifier to create user
            return User(dictionary: userDictionary, identifier: "uid")
        }
        
        set {
            
            if newValue != nil {
                // TODO: Finish actually saving to user defaults
                NSUserDefaults.standardUserDefaults()
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kUser)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    
    static let sharedController = UserController()
    
    static func userForIdentifier(identifier: String, completion: (user: User?) -> Void) {
        FirebaseController.ref.child(User.userKey).child(identifier).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // TODO: Parse snapshot data
//            if let json = data as? [String: AnyObject] {
//                let user = User(json: json, identifier: identifier)
//                completion(user: user)
//            } else {
//                completion(user: nil)
//            }
        })
    }
    
    static func fetchAllUsers(completion: (users: [User]) -> Void) {
        FirebaseController.ref.child(User.userKey).queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { snapshot in
            // TODO: Parse snapshot data
//            if let json = data as? [String: AnyObject] {
//                
//                let users = json.flatMap({User(json: $0.1 as! [String : AnyObject], identifier: $0.0)})
//                
//                completion(users: users)
//                
//            } else {
//                completion(users: [])
//            }
        })
    }
    
    static func followUser(user: User, completion: (success: Bool) -> Void) {
        
        FirebaseController.ref.child("\(sharedController.currentUser.identifiedEndpoint)/follows/\(user.identifier)").setValue(true)
        
        completion(success: true)
    }
    
    static func unfollowUser(user: User, completion: (success: Bool) -> Void) {
        
        FirebaseController.ref.child("\(sharedController.currentUser.identifiedEndpoint)/follows/\(user.identifier)").removeValue()
        
        completion(success: true)
    }
    
    static func userFollowsUser(user: User, followsUser: User, completion: (follows: Bool) -> Void ) {
        
        FirebaseController.ref.child("\(user.identifiedEndpoint)/follows/\(followsUser.identifier)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // TODO: Parse snapshot data
//            if let _ = data {
//                completion(follows: true)
//            } else {
//                completion(follows: false)
//            }
        })
    }
    
    static func followedByUser(user: User, completion: (followed: [User]?) -> Void) {
        
//        FirebaseController.newEndpoint("/users/\(user.identifier!)/follows/") { (data) -> Void in
//            
//            if let json = data as? [String: AnyObject] {
//                
//                var users: [User] = []
//                
//                for userJson in json {
//                    
//                    userForIdentifier(userJson.0, completion: { (user) -> Void in
//                        
//                        if let user = user {
//                            users.append(user)
//                            completion(followed: users)
//                        }
//                    })
//                }
//            } else {
//                completion(followed: [])
//            }
//        }
        
    }
    
    static func authenticateUser(email: String, password: String, completion: (success: Bool, user: User?) -> Void) {
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            // TODO: Parse signed in user
            
            if let user = user where error == nil {
                print("User ID: \(user.uid) authenticated successfully.")
                UserController.userForIdentifier(user.uid, completion: { (user) -> Void in
                    
                    if let user = user {
                        sharedController.currentUser = user
                    }
                    
                    completion(success: true, user: user)
                })
            } else {
                print("Unsuccessful login attempt.")
                completion(success: false, user: nil)
            }
        })
    }
    
    static func createUser(firstName: String, lastName: String, email: String, username: String, password: String, bio: String?, url: String?, completion: (success: Bool, user: User?) -> Void) {
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if let user = user where error == nil {
                var user = User(username: username, firstName: firstName, lastName: lastName, email: email, bio: bio, URL: url, identifier: user.uid)
                user.save()
                completion(success: true, user: user)
            } else {
                completion(success: false, user: nil)
            }
        })
    }
    
    static func updateUser(user: User, username: String, bio: String?, url: String?, completion: (success: Bool, user: User?) -> Void) {
        var updatedUser = user
        updatedUser.username = username
        updatedUser.bio = bio
        updatedUser.url = url
        updatedUser.save()
    }
    
    static func logoutCurrentUser() {
        _ = try? FIRAuth.auth()?.signOut()
        UserController.sharedController.currentUser = nil
    }
    
/*    static func mockUsers() -> [User] {
        
        let user1 = User(username: "drvenkman", uid: "1234")
        let user2 = User(username: "drspengler", uid: "2356")
        let user3 = User(username: "drstantz: "3456")
        let user4 = User(username: "winstonzeddemore", uid: "4567", bio: "Ghostbuster", url: "iaintfraidofnoghost.com")
        
        return [user1, user2, user3, user4]
    }
 */


}