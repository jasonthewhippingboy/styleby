//
//  Fashion911TableViewController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/25/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import UIKit

class Fashion911TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var image: UIImage?
    var whatsYourEmergency: String?
    @IBOutlet weak var fashion911Button: UIButton!
    @IBOutlet weak var whatsYourEmergencyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func fashion911ButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) -> Void in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.image = image
        fashion911Button.setTitle("", for: UIControlState())
        fashion911Button.setBackgroundImage(self.image, for: UIControlState())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        whatsYourEmergency = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func submitButtonTapped() {
        self.view.window?.endEditing(true)
        if let image = image  {
            
            //Fashion911 IMAGE
            
           Fashion911Controller.addFashion911(image, whatsYourEmergency: self.whatsYourEmergency, completion: { (success, fashion911) -> Void in
                if fashion911 != nil {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let failedAlert = UIAlertController(title: "Failed!", message: "Image failed to Fashion911. Please try again.", preferredStyle: .alert)
                    failedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(failedAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
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
