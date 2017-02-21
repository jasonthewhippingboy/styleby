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
    
    func uploadImageToFirebaseStorage(_ data: Data) {
        let storageRef = FIRStorage.storage().reference().child("my pics").child("demoPic.jpg")
        let uploadMetaData = FIRStorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        let uploadTask = storageRef.put(data, metadata: uploadMetaData) { (metadata, error) in
            if (error != nil) {
                print("Post did not load \(error!.localizedDescription)")
            } else {
                print("Upload complete! \(metadata)")
                
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(image, 0.8) {
            uploadImageToFirebaseStorage(imageData)
            
            self.image = image
        }
        
        addPhotoButton.setTitle("", for: UIControlState())
        addPhotoButton.setBackgroundImage(self.image, for: UIControlState())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let failedAlert = UIAlertController(title: "Failed!", message: "Image failed to post. Please try again.", preferredStyle: .alert)
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
