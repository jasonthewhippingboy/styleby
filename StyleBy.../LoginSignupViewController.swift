//
//  LoginSignupViewController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/1/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import UIKit

class LoginSignupViewController: UIViewController {

    enum ViewMode {
        case login
        case signup
        case edit
    }
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var viewMode = ViewMode.signup
    var fieldsAreValid: Bool {
        get {
            switch viewMode {
            case .login:
                return !(emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty)
            case .signup:
                return !(usernameTextField.text!.isEmpty || firstNameTextField.text!.isEmpty || lastNameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty)
            case .edit:
                return !(usernameTextField.text!.isEmpty)
            }
        }
    }
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewBasedOnMode()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateViewBasedOnMode() {
        switch viewMode {
        case .login:
            firstNameTextField.isHidden = true
            lastNameTextField.isHidden = true
            usernameTextField.isHidden = true
            bioTextField.isHidden = true
            urlTextField.isHidden = true
            
            actionButton.setTitle("Login", for: UIControlState())
        case .signup:
            actionButton.setTitle("Signup", for: UIControlState())
        case .edit:
            actionButton.setTitle("Update", for: UIControlState())
            
            emailTextField.isHidden = true
            passwordTextField.isHidden = true
            
            if let user = self.user {
                
                usernameTextField.text = user.username
                firstNameTextField.text = user.firstName
                lastNameTextField.text = user.lastName
                bioTextField.text = user.bio
                urlTextField.text = user.url
                
            }
        }
    }
    
    func updateWithCurrentUser() {
        self.user = UserController.sharedController.currentUser
        viewMode = .edit
    }
    
    @IBAction func actionButtonTapped() {
        
        if fieldsAreValid {
            switch viewMode {
            case .login:
                UserController.authenticateUser(emailTextField.text!, password: passwordTextField.text!, completion: { (success, user) -> Void in
                    
                    if success, let _ = user {
                        guard let initial = self.presentingViewController as? ViewController else { fatalError() }
                        self.dismiss(animated: true, completion: nil)
                        initial.performSegueBasedOnUserStatus()
                    } else {
                        self.presentValidationAlertWithTitle("Unable to Log In", message: "Please check your information and try again.")
                    }
                })
            case .signup:
                print(emailTextField.text)
                UserController.createUser(username: usernameTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, bio: bioTextField.text, url: urlTextField.text, completion: { (success, user) -> Void in
                    
                    if success, let _ = user {
                        guard let initial = self.presentingViewController as? ViewController else { fatalError() }
                        self.dismiss(animated: true) {
                        initial.performSegueBasedOnUserStatus()
                        }
                    } else {
                        self.presentValidationAlertWithTitle("Unable to Signup", message: "Please check your information and try again.")
                    }
                })
            case .edit:
                UserController.updateUser(self.user!, username: self.usernameTextField.text!, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, bio: self.bioTextField.text, url: self.urlTextField.text, completion: { (success) -> Void in
                    
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.presentValidationAlertWithTitle("Unable to Update User", message: "Please check your information and try again.")
                    }
                })
            }
        } else {
            presentValidationAlertWithTitle("Missing Information", message: "Please check your information and try again.")
        }
        
    }
    
    func presentValidationAlertWithTitle(_ title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
