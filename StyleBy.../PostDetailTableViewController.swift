//
//  PostDetailTableViewController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/1/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {

    var post: Post?
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        updateBasedOnPost()
    }
    
    func updateBasedOnPost() {
        guard let post = post else { return }
        
        self.likesLabel.text = "\(post.likes.count) likes"
        self.commentsLabel.text = "\(post.comments.count) comments"
        
        ImageController.imageForIdentifier(post.imageEndpoint) { (image) -> Void in
            self.headerImageView.image = image
        }
        
        tableView.reloadData()
    }
    
    @IBAction func likeTapped(_ sender: AnyObject) {
        
        PostController.addLikeToPost(post!) { (success, post) -> Void in
            
            if let post = post {
                self.post = post
                self.updateBasedOnPost()
            }
        }
    }
    
    @IBAction func addCommentTapped(_ sender: AnyObject) {
        
        let commentAlert = UIAlertController(title: "Add Comment", message: nil, preferredStyle: .alert)
        
        commentAlert.addTextField { (textfield) -> Void in
            textfield.placeholder = "Comment"
        }
        
        commentAlert.addAction(UIAlertAction(title: "Add Comment", style: .default, handler: { (action) -> Void in
            
            if let text = commentAlert.textFields?.first?.text {
                
                PostController.addCommentWithTextToPost(text, post: self.post!, completion: { (success, post) -> Void in
                    
                    if let post = post {
                        self.post = post
                        self.updateBasedOnPost()
                    }
                })
            }
        }))
        
        commentAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(commentAlert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return post!.comments.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row]
        
        if let comment = comment {
            cell.textLabel?.text = comment.username
            cell.detailTextLabel?.text = comment.text
        }
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
