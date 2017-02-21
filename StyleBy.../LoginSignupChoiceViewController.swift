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


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "toSignUp" {
            let destinationViewController = segue.destination as? LoginSignupViewController
            destinationViewController?.viewMode = LoginSignupViewController.ViewMode.signup
        } else if segue.identifier == "toLogin" {
            let destinationViewController = segue.destination as? LoginSignupViewController
            destinationViewController?.viewMode = LoginSignupViewController.ViewMode.login
        }
        
    }
    
}
