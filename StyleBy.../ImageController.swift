//
//  ImageController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/27/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import Foundation
import UIKit

class ImageController {
    
    static func uploadImage(image: UIImage, identifier: String, completion: (success: Bool) -> Void) {
        
        if let base64Image = image.base64String {
            let base = FirebaseController.ref.child("images")
            base.child(identifier).setValue(base64Image, withCompletionBlock: { (error, ref) in
                guard error == nil else { completion(success: false); return }
                completion(success: true)
            })
            
        }
    }
    
    static func imageForIdentifier(identifier: String, completion: (image: UIImage?) -> Void) {
        
        FirebaseController.ref.child("images/\(identifier)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            guard let base64String = snapshot.value as? String else {
                completion(image: nil)
                return
            }
          let image = UIImage(base64: base64String)
            completion (image: image)
        })
    }
}

extension UIImage {
    var base64String: String? {
        guard let data = UIImageJPEGRepresentation(self, 0.8) else {
            return nil
        }
        
        return data.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    
    convenience init?(base64: String) {
        
        if let imageData = NSData(base64EncodedString: base64, options: .IgnoreUnknownCharacters) {
            self.init(data: imageData)
        } else {
            return nil
        }
    }
}