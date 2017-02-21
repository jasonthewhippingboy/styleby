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
    
    func updateWithUser(_ user: User) {
        if let bio = user.bio {
            bioLabel.text = bio
        } else {
            bioLabel.isHidden = true
        }
        
        if let url = user.url {
            urlButton.setTitle(url, for: UIControlState())
        } else {
            urlButton.isHidden = true
        }
        
        if user == UserController.sharedController.currentUser {
            followButton.setTitle("Logout", for: UIControlState())
        } else {
            
            guard let currentUser = UserController.sharedController.currentUser else {
                return
            }
            UserController.sharedController.userFollowsUser(currentUser, followsUser: user, completion: { (follows) -> Void in
                if (follows != nil) {
                    self.followButton.setTitle("Unfollow", for: UIControlState())
                } else {
                    self.followButton.setTitle("Follow", for: UIControlState())
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
