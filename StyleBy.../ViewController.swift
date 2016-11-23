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
    }
    private let kFirstName = "firstName"
    private let kUser = "userKey"
    
    func retrieveFirstName() {
        
        guard let userDictionary = NSUserDefaults.standardUserDefaults().valueForKey(kUser) as? [String: AnyObject], firstName = userDictionary[kFirstName] as? String else { return }
        
        
        self.userName.text = firstName
    }
    
    func viewWillAppear() {
        if UserController.sharedController.currentUser != nil {
            performSegueWithIdentifier("currentUser", sender: nil)
        } else {
            performSegueWithIdentifier("noUser", sender: nil)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

