//
//  AddPhotoTableViewController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/1/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import UIKit
import Firebase

class AddPhotoTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var image: UIImage?
    var topBy: String?
    var bottomBy: String?
    var shoesBy: String?
    var accessoriesBy: String?
    var whatsYourEmergency: String?
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var topByTextField: UITextField!
    @IBOutlet weak var bottomByTextField: UITextField!
    @IBOutlet weak var shoesByField: UITextField!
    @IBOutlet weak var accessoriesByField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func addPhotoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func uploadImageToFirebaseStorage(data: NSData) {
        let storageRef = FIRStorage.storage().reference().child("my pics").child("demoPic.jpg")
        let uploadMetaData = FIRStorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        let uploadTask = storageRef.putData(data, metadata: uploadMetaData) { (metadata, error) in
            if (error != nil) {
                print("Post did not load \(error!.localizedDescription)")
            } else {
                print("Upload complete! \(metadata)")
                
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, imageData = UIImageJPEGRepresentation(image, 0.8) {
            uploadImageToFirebaseStorage(imageData)
            
            self.image = image
        }
        
        addPhotoButton.setTitle("", forState: .Normal)
        addPhotoButton.setBackgroundImage(self.image, forState: .Normal)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        topBy = textField.text
        bottomBy = textField.text
        shoesBy = textField.text
        accessoriesBy = textField.text
        whatsYourEmergency = textField.text
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func submittButtonTapped() {
        self.view.window?.endEditing(true)
        if let image = image  {
            
            //POST IMAGE
            
            PostController.addPost(image, topBy: "Top By: \(self.topBy)", bottomBy: "Bottom By: \(self.bottomBy)", shoesBy: "Shoes By: \(self.shoesBy)", accessoriesBy: "Accessories By: \(self.accessoriesBy)", completion: { (success, post) -> Void in
                if post != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    let failedAlert = UIAlertController(title: "Failed!", message: "Image failed to post. Please try again.", preferredStyle: .Alert)
                    failedAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(failedAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func cancelButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
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