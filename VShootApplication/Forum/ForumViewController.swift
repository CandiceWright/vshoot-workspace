//
//  ForumViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 7/7/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class ForumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    //in login (view controller), I hardcoded the posts value. need to remove this once you pull posts from db
    
    var posts:[ForumPost] = [];
    var dataString: String = "";
    
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var ForumPostsTableView: UITableView!
    @IBOutlet weak var postBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(posts[0].postText)
        self.postTextView.delegate = self
        postTextView.text = "Looking for people to vshoot with? Want to say hi to the community? Post a message here."
        postTextView.textColor = .lightGray
        postTextView.layer.borderColor = UIColor.lightGray.cgColor
        postTextView.layer.borderWidth = 1.0
        postBtn.isEnabled = false
        postBtn.alpha = 0.1
        postBtn.layer.cornerRadius = CGFloat(Float(4.0))
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewTapped), name: UITextView.textDidBeginEditingNotification, object: nil)
        
        self.hideKeyboard()
    }
    @IBAction func postToForum(_ sender: Any) {
        
        let postText = self.postTextView.text
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        let dateStr = formatter.string(from: date)
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/posts"
        print("printing userId before posting")
        print(SocketIOManager.sharedInstance.currUserObj.userId)
        let info: [String:Any] = ["postUser": SocketIOManager.sharedInstance.currUserObj.userId as Any, "postText": postText as Any, "postDate": dateStr as Any]
        //"securityQuestion": self.question as Any, "securityAnswer": SQAnswer.text as Any
        do {
            let data = try JSONSerialization.data(withJSONObject: info, options: [])
            dataString = String(data: data, encoding: .utf8)!
        } catch {
            print("error")
        }
        
        let url = URL(string: posturl);
        
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<201)
            .responseJSON{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print(data)
                   if let json = data as? Dictionary<String,String>{
                    print(json["successful"]!)
                    if (json["successful"] == "true"){
                        let newPost = ForumPost.init(forumId: Int(json["postId"]!)!, postText: postText!, username: SocketIOManager.sharedInstance.currUserObj.username, datePosted: dateStr,  numLikes: 0, numComments: 0)
                            
                        //self.posts.append(newPost)
                        self.posts.insert(newPost, at: 0)
                        self.ForumPostsTableView.reloadData()
                    }
                    else {
                        let alertController = UIAlertController(title: "Oops!", message:
                            "There was a problem saving your post. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in  }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                        
                    }
                    else {
                        let alertController = UIAlertController(title: "Oops!", message:
                            "There was a problem saving your post. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in  }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
        }
        
    }
    
    @objc func textChanged(sender: NSNotification) {
        if (self.postTextView.hasText && postTextView.text != "Looking for people to vshoot with? Want to say hi to the community? Post a message here."){
            postBtn.isEnabled = true
            postBtn.alpha = 1.0
        }
        else {
            postBtn.isEnabled = false
            postBtn.alpha = 0.1
        }
    }
    
    @objc func textViewTapped(sender: NSNotification){
        if(self.postTextView.text == "Looking for people to vshoot with? Want to say hi to the community? Post a message here."){
            postTextView.text = ""
            postTextView.textColor = .black
        }
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
        cell.dateLabel.text = posts[indexPath.row].datePosted
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
