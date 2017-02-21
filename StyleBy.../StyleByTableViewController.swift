//
//  StyleByTableViewController.swift
//  StyleBy...
//
//  Created by Elizabeth Earl on 10/1/16.
//  Copyright © 2016 Jason. All rights reserved.
//

import UIKit

class StyleByTableViewController: UITableViewController {

    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentUser = UserController.sharedController.currentUser {
                loadStyleFeedForUser(currentUser)
            
        } else {
            tabBarController?.performSegue(withIdentifier: "noCurrentUserSegue", sender:nil)
        }
    }
    
    func loadStyleFeedForUser (_ user: User) {
        PostController.fetchStyleFeedForUser(user) { (posts) -> Void in
            if let posts = posts {
                self.posts = posts
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                })
            } else {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        let post = posts[indexPath.row]
        
        cell.updateWithPost(post)
        
        return cell
    }
    
    @IBAction func userRefreshedTable() {
        
        guard let currentUser = UserController.sharedController.currentUser else {
            return
        }
        loadStyleFeedForUser(currentUser)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stylebyToPostDetail" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                
                let post = posts[indexPath.row]
                
                let destinationViewController = segue.destination as? PostDetailTableViewController
                
                destinationViewController?.post = post
            }
        }
    }
    
    
}
