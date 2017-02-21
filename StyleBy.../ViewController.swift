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
        perform(#selector(ViewController.performSegueBasedOnUserStatus), with: nil, afterDelay: 3)
    }
    fileprivate let kFirstName = "firstName"
    fileprivate let kUser = "userKey"
    
    func retrieveFirstName() {
        
        guard let userDictionary = UserDefaults.standard.value(forKey: kUser) as? [String: AnyObject], let firstName = userDictionary[kFirstName] as? String else { return }
        
        
        self.userName.text = firstName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    func performSegueBasedOnUserStatus() {
        if UserController.sharedController.currentUser != nil {
            performSegue(withIdentifier: "currentUser", sender: self)
        } else {
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "noUser", sender: self)
            })
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
}

