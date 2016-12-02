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
    
    func fetchUserData(identifier: String, completion: (user: User?) -> Void) {
        
        let userRef = FirebaseController.ref.child("users").child(identifier)
        userRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            // Retrieve the results from the returned snapshot
            guard let userDictionary = snapshot.value as? [String: String] else {
                completion(user: nil)
                return
            }
            let user = User(dictionary: userDictionary, identifier: identifier)
            completion(user: user)
            
            return
            
        })
    }
    var currentUser: User? {
        get {
            
            
            guard let userDictionary = NSUserDefaults.standardUserDefaults().valueForKey(kUser) as? [String: AnyObject],
            let userId = FIRAuth.auth()?.currentUser?.uid else {
                return nil
            }
            
            return User(dictionary: userDictionary, identifier: userId)
        }
        
        set {
            
            if let newValue = newValue {
                NSUserDefaults.standardUserDefaults().setValue(newValue.dictionaryCopy, forKey: kUser)
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
            guard let userDictionary = snapshot.value as? [String: String] else {
                completion(user: nil)
                return
            }
            // Create a user object with the data returned
            let user = User(dictionary: userDictionary, identifier: identifier)
            completion(user: user)
        })
    }
    
    static func fetchAllUsers(completion: (users: [User]?) -> Void) {
        FirebaseController.ref.child(User.userKey).queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { snapshot in
            guard let userDictionary = snapshot.value as? [User] else {
                completion(users: nil)
                return
            }
            let user = userDictionary
            completion(users: user)
            //            }
        })
    }
    
    func followUser(user: User, completion: (success: Bool) -> Void) {
        
        guard let currentUser = currentUser else {
            completion(success: false)
            return
        }
        
        FirebaseController.ref.child("\(currentUser.identifiedEndpoint)/follows/\(user.identifier)").setValue(true)
        
        completion(success: true)
    }
    
    
    func unfollowUser(user: User, completion: (success: Bool) -> Void) {
        
        guard let currentUser = currentUser else {
            completion(success: false)
            return
        }
        
        FirebaseController.ref.child("\(currentUser.identifiedEndpoint)/follows/\(user.identifier)").removeValue()
        
        completion(success: true)
    }
    
    func userFollowsUser(user: User, followsUser: User, completion: (follows: String?) -> Void ) {
        
        FirebaseController.ref.child("\(user.identifiedEndpoint)/follows/\(followsUser.identifier)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let followsDictionary = snapshot.value as? String else {
                completion(follows: nil)
                return
            }
            let follows = followsDictionary
            completion(follows: follows)
        })
    }
    
    func followedByUser(user: User, completion: (followed: [User]?) -> Void) {
        
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
    
    static func createUser(username username: String, firstName: String, lastName: String, email: String, password: String, bio: String?, url: String?, completion: (success: Bool, user: User?) -> Void) {
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if let user = user where error == nil {
                var user = User(username: username, firstName: firstName, lastName: lastName, email: email, bio: bio, URL: url, identifier: user.uid)
                user.save()
                completion(success: true, user: user)
            } else {
                print(error?.localizedDescription)
                completion(success: false, user: nil)
            }
        })
    }
    
    static func updateUser(user: User, username: String, firstName: String, lastName: String, bio: String?, url: String?, completion: (success: Bool, user: User?) -> Void) {
        var updatedUser = user
        updatedUser.username = username
        updatedUser.firstName = firstName
        updatedUser.lastName = lastName
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