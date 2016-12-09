//
//  Firebase Controller.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/29/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseController {

    static let ref = FIRDatabase.database().reference()
    static let storageRef = FIRStorage.storage().reference()
}

protocol FirebaseType {
    var endpoint: String {get}
    var identifier: String? {get set}
    var dictionaryCopy: [String: AnyObject] {get}
    
    init?(dictionary: [String: AnyObject], identifier: String)
    
    mutating func save(completion: ((NSError?) -> ())?)
    func delete()
}

extension FirebaseType {
    
    mutating func save(completion: ((NSError?) -> ())? = nil) {
        var newEndpoint = FirebaseController.ref.child(endpoint)
        if let identifier = identifier {
            newEndpoint = newEndpoint.child(identifier)
        } else {
            newEndpoint = newEndpoint.childByAutoId()
            self.identifier = newEndpoint.key
        }
        newEndpoint.updateChildValues(dictionaryCopy) { (error, ref) in
            completion?(error)
        }
    }
    
    func delete() {
        guard let identifier = identifier else {
            return
        }
        FirebaseController.ref.child(endpoint).child(identifier).removeValue()
    }
}