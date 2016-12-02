//
//  ViewController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 9/24/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        retrieveFirstName()
        performSelector(#selector(ViewController.performSegueBasedOnUserStatus), withObject: nil, afterDelay: 3)
    }
    private let kFirstName = "firstName"
    private let kUser = "userKey"
    
    func retrieveFirstName() {
        
        guard let userDictionary = NSUserDefaults.standardUserDefaults().valueForKey(kUser) as? [String: AnyObject], firstName = userDictionary[kFirstName] as? String else { return }
        
        
        self.userName.text = firstName
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    func performSegueBasedOnUserStatus() {
        if UserController.sharedController.currentUser != nil {
            performSegueWithIdentifier("currentUser", sender: self)
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("noUser", sender: self)
            })
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
}

