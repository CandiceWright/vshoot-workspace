//
//  ForumViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 7/7/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import UIKit

class ForumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //in login (view controller), I hardcoded the posts value. need to remove this once you pull posts from db
    
    var posts:[ForumPost] = [];
    
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var ForumPostsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(posts[0].postText)
//        posts.append(post1)
//        posts.append(post2)
//        self.ForumPostsTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    @IBAction func postToForum(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(posts.count)
        return posts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ForumPostsTableView.dequeueReusableCell(withIdentifier: "ForumCell") as! ForumTableViewCell
        cell.cellRow = indexPath.row
        cell.username.text = posts[indexPath.row].username
        cell.postText.text = posts[indexPath.row].postText
        cell.numComments.text = String(posts[indexPath.row].numComments)
        cell.numLikes.text = String(posts[indexPath.row].numLikes)
        cell.delegate = self
            
            return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ForumViewController: ForumTableViewCellDelegate {
    func didTapLikeBtn(rowSelected: Int) {
        print("curr user just liked a post with message ")
        print(self.posts[rowSelected].postText)
        print(" with forum id ")
        print(self.posts[rowSelected].forumId)
    }
    
    func didTapCommentBtn(rowSelected: Int) {
        print("comment button tapped")
    }
    
    
}
