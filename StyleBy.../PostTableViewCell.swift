//
//  PostTableViewCell.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/1/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    func updateWithPost(_ post: Post) {
        self.postImageView.image = nil
        
        self.likesLabel.text = "\(post.likes.count) likes"
        self.commentsLabel.text = "\(post.comments.count) comments"
        
        ImageController.imageForIdentifier(post.imageEndpoint) { (image) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.postImageView.image = image
            })
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
