//
//  ImageCollectionViewCell.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/1/16.
//  Copyright © 2016 Jason. All rights reserved.
//
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func updateWithImageIdentifier(_ identifier: String) {
        
        ImageController.imageForIdentifier(identifier) { (image) -> Void in
            self.imageView.image = image
        }
        
    }
    
}
