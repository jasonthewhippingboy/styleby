//
//  ImageController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ImageController {
    
    static func uploadImage(_ image: UIImage, identifier: String, completion: @escaping (_ success: Bool) -> Void) {
        
        if let base64Image = image.base64String {
            let base = FirebaseController.ref.child("images")
            base.child(identifier).setValue(base64Image, withCompletionBlock: { (error, ref) in
                guard error == nil else { completion(false); return }
                completion(true)
            })
            
        }
    }
    
    static func imageForIdentifier(_ identifier: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        FirebaseController.ref.child(identifier).observeSingleEvent(of: .value, with: { snapshot in
            guard let base64String = snapshot.value as? String else {
                completion(nil)
                return
            }
          let image = UIImage(base64: base64String)
            completion (image)
        })
    }
}

extension UIImage {
    var base64String: String? {
        guard let data = UIImageJPEGRepresentation(self, 0.8) else {
            return nil
        }
        
        return data.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    convenience init?(base64: String) {
        
        if let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) {
            self.init(data: imageData)
        } else {
            return nil
        }
    }
}
