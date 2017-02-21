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
    
    fileprivate let kUser = "userKey"
    
    // TODO: Use this some time
    func fetchUserData(_ identifier: String, completion: @escaping (_ user: User?) -> Void) {
        
        let userRef = FirebaseController.ref.child("user").child(identifier)
        userRef.observeSingleEvent(of: .value, with:  { (snapshot) in
            // Retrieve the results from the returned snapshot
            guard let userDictionary = snapshot.value as? [String: String] else {
                completion(nil)
                return
            }
            let user = User(dictionary: userDictionary as [String : AnyObject], identifier: identifier)
            completion(user)
            
            return
            
        })
    }
    var currentUser: User? {
        get {
            
            
            guard let userDictionary = UserDefaults.standard.value(forKey: kUser) as? [String: AnyObject],
            let userId = FIRAuth.auth()?.currentUser?.uid else {
                return nil
            }
            
            return User(dictionary: userDictionary, identifier: userId)
        }
        
        set {
            
            if let newValue = newValue {
                UserDefaults.standard.setValue(newValue.dictionaryCopy, forKey: kUser)
                UserDefaults.standard.synchronize()
            } else {
                UserDefaults.standard.removeObject(forKey: kUser)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    
    
    
    static let sharedController = UserController()
    
    static func userForIdentifier(_ identifier: String, completion: @escaping (_ user: User?) -> Void) {
        FirebaseController.ref.child(User.userKey).child(identifier).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: String] else {
                completion(nil)
                return
            }
            // Create a user object with the data returned
            let user = User(dictionary: userDictionary as [String : AnyObject], identifier: identifier)
            completion(user)
        })
    }
    
    static func fetchAllUsers(_ completion: @escaping (_ users: [User]?) -> Void) {
        FirebaseController.ref.child(User.userKey).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            guard let userDictionary = snapshot.value as? [User] else {
                completion(nil)
                return
            }
            let user = userDictionary
            completion(user)
            //            }
        })
    }
    
    func followUser(_ user: User, completion: (_ success: Bool) -> Void) {
        
        guard let currentUser = currentUser else {
            completion(false)
            return
        }
        
        FirebaseController.ref.child("\(currentUser.identifiedEndpoint)/follows/\(user.identifier)").setValue(true)
        
        completion(true)
    }
    
    
    func unfollowUser(_ user: User, completion: (_ success: Bool) -> Void) {
        
        guard let currentUser = currentUser else {
            completion(false)
            return
        }
        
        FirebaseController.ref.child("\(currentUser.identifiedEndpoint)/follows/\(user.identifier)").removeValue()
        
        completion(true)
    }
    
    func userFollowsUser(_ user: User, followsUser: User, completion: @escaping (_ follows: String?) -> Void ) {
        
        FirebaseController.ref.child("\(user.identifiedEndpoint)/follows/\(followsUser.identifier)").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followsDictionary = snapshot.value as? String else {
                completion(nil)
                return
            }
            let follows = followsDictionary
            completion(follows)
        })
    }
    
    func followedByUser(_ user: User, completion: @escaping (_ followed: [User]?) -> Void) {
        FirebaseController.ref.child("\(user.identifiedEndpoint)/follows").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followedByDictionary = snapshot.value as? [String: Bool] else {
                completion(nil)
                return
            }
            let followIdentifiers = Array(followedByDictionary.keys)
            let dispatchGroup = DispatchGroup()
            var followedUsers = [User]()
            
            for identifier in followIdentifiers {
                dispatchGroup.enter()
                self.fetchUserData(identifier, completion: { (user) in
                    if let user = user {
                        followedUsers.append(user)
                    }
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main, execute: { () -> Void in
                completion(followedUsers)
            })
        })
    }
    
    static func authenticateUser(_ email: String, password: String, completion: @escaping (_ success: Bool, _ user: User?) -> Void) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            // TODO: Parse signed in user
            
            if let user = user, error == nil {
                print("User ID: \(user.uid) authenticated successfully.")
                UserController.userForIdentifier(user.uid, completion: { (user) -> Void in
                    
                    if let user = user {
                        sharedController.currentUser = user
                    }
                    
                    completion(true, user)
                })
            } else {
                print("Unsuccessful login attempt.")
                completion(false, nil)
            }
        })
    }
    
    static func createUser(username: String, firstName: String, lastName: String, email: String, password: String, bio: String?, url: String?, completion: @escaping (_ success: Bool, _ user: User?) -> Void) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let user = user, error == nil {
                var user = User(username: username, firstName: firstName, lastName: lastName, email: email, bio: bio, URL: url, identifier: user.uid)
                user.save { error in
                    completion(error == nil, user)
                }
            } else {
                print(error?.localizedDescription)
                completion(false, nil)
            }
        })
    }
    
    static func updateUser(_ user: User, username: String, firstName: String, lastName: String, bio: String?, url: String?, completion: @escaping (_ success: Bool) -> Void) {
        var updatedUser = user
        updatedUser.username = username
        updatedUser.firstName = firstName
        updatedUser.lastName = lastName
        updatedUser.bio = bio
        updatedUser.url = url
        updatedUser.save { error in
            if let _ = error {
                completion(false)
            } else {
                UserController.sharedController.currentUser = updatedUser
                completion(error == nil)
            }
        }
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
