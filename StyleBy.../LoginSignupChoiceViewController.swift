//
//  LoginSignupChoiceViewController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/1/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import UIKit


class LoginSignupChoiceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        
        if segue.identifier == "toSignUp" {
            let destinationViewController = segue.destinationViewController as? LoginSignupViewController
            destinationViewController?.viewMode = LoginSignupViewController.ViewMode.Signup
        } else if segue.identifier == "toLogin" {
            let destinationViewController = segue.destinationViewController as? LoginSignupViewController
            destinationViewController?.viewMode = LoginSignupViewController.ViewMode.Login
        }
        
    }
    
}