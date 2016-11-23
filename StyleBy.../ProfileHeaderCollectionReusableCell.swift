//
//  ProfileHeaderCollectionReusableCell.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/1/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import UIKit

protocol ProfileHeaderCollectionReusableViewDelegate {

    func userTappedFollowActionButton()
    func userTappedURLButton()
    
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var urlButton: UIButton!
    
    var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    func updateWithUser(user: User) {
        if let bio = user.bio {
            bioLabel.text = bio
        } else {
            bioLabel.hidden = true
        }
        
        if let url = user.url {
            urlButton.setTitle(url, forState: .Normal)
        } else {
            urlButton.hidden = true
        }
        
        if user == UserController.sharedController.currentUser {
            followButton.setTitle("Logout", forState: .Normal)
        } else {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                return
            }
            UserController.sharedController.userFollowsUser(currentUser, followsUser: user, completion: { (follows) -> Void in
                if (follows != nil) {
                    self.followButton.setTitle("Unfollow", forState: .Normal)
                } else {
                    self.followButton.setTitle("Follow", forState: .Normal)
                }
            })
            
        }
    }
    
    @IBAction func urlButtonTapped() {
        delegate?.userTappedURLButton()
    }
    
    @IBAction func followActionButtonTapped() {
        delegate?.userTappedFollowActionButton()
    }
    
}