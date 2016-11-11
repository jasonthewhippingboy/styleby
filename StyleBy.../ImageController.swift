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
    
    static func uploadImage(image: UIImage, completion: (identifier: String?) -> Void) {
        
        if let base64Image = image.base64String {
            let base = FirebaseController.ref.child("images")
            base.setValue(base64Image)
            
            completion(identifier: base.key)
        } else {
            completion(identifier: nil)
        }
    }
    
    static func imageForIdentifier(identifier: String, completion: (image: UIImage?) -> Void) {
        
        FirebaseController.ref.child("images/\(identifier)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            // TODO: Parse snapshot as image data
//            if let data = data as? String {
//                let image = UIImage(base64: data)
//                completion(image: image)
//            } else {
//                completion(image: nil)
//            }
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