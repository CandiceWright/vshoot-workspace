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
    var selectedBtnRow: Int = 0
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var ForumPostsTableView: UITableView!
    @IBOutlet weak var postBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        ForumPostsTableView.tableFooterView = UIView()
        self.ForumPostsTableView.isHidden = true
        getPosts()
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
    
    override func viewWillAppear(_ animated: Bool) {
        print("view appeared")
        self.ForumPostsTableView.reloadData()
        postTextView.text = "Looking for people to vshoot with? Want to say hi to the community? Post a message here."
        postTextView.textColor = .lightGray
    }
    
    func getPosts(){
        print("user id in get posts" + SocketIOManager.sharedInstance.currUserObj.userId)
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/posts/all/" + SocketIOManager.sharedInstance.currUserObj.userId
                let url = URL(string: geturl)
                Alamofire.request(url!)
                    .validate(statusCode: 200..<201)
                    .responseJSON{ (response) in
                        switch response.result {
                        case .success(let data):
                            print(data)
                            self.ForumPostsTableView.isHidden = false
                            if let postsDict = data as? [Dictionary<String,String>]{
                                SocketIOManager.sharedInstance.forumPosts.removeAll()
                                for item in postsDict.reversed() {
                                    let post = ForumPost.init(forumId: Int(item["postId"]!)!, postText: item["postText"]!, username: item["posterUsername"]!, imageUrl: item["postUserProfilePic"]!, datePosted: item["postDate"]!, numLikes: Int(item["numPostLikes"]!)!, numComments: Int(item["numPostComments"]!)!, didLikePost: item["didLikePost"]!)
                                    if (item["postUserProfilePic"]! != "none"){
                                       ImageService.getImage(withURL: item["postUserProfilePic"]!, completion: {image in
                                                                                  print("got image")
                                        post.image = image
                                                                              })
                                        
                                    }
                                    
                                    self.posts.append(post)
                                    SocketIOManager.sharedInstance.forumPosts.append(post)
                                }
                                self.ForumPostsTableView.reloadData()
                            }
                            else {
                                print("cannot convert to dict")
                                let alertController = UIAlertController(title: "Sorry!", message:
                                    "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                                
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
    @IBAction func postToForum(_ sender: Any) {
        self.postBtn.isEnabled = false;
        self.postBtn.alpha = 0.1
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
                        self.postTextView.text = "Looking for people to vshoot with? Want to say hi to the community? Post a message here."
                        self.postTextView.textColor = .lightGray
                        let newPost = ForumPost.init(forumId: Int(json["postId"]!)!, postText: postText!, username: SocketIOManager.sharedInstance.currUserObj.username, imageUrl: SocketIOManager.sharedInstance.currUserObj.imageUrl,datePosted: dateStr,  numLikes: 0, numComments: 0, didLikePost: "false")
                            
                        //self.posts.append(newPost)
                        self.posts.insert(newPost, at: 0)
                        SocketIOManager.sharedInstance.forumPosts.insert(newPost, at: 0)
                        self.ForumPostsTableView.reloadData()
                    }
                    else {
                        self.postBtn.isEnabled = true
                        self.postBtn.alpha = 1.0
                        let alertController = UIAlertController(title: "Oops!", message:
                            "There was a problem saving your post. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in  }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                        
                    }
                    else {
                    self.postBtn.isEnabled = true
                    self.postBtn.alpha = 1.0
                        let alertController = UIAlertController(title: "Oops!", message:
                            "There was a problem saving your post. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in  }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                    self.postBtn.isEnabled = true
                    self.postBtn.alpha = 1.0
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
        print(SocketIOManager.sharedInstance.forumPosts.count)
        //return posts.count;
        return SocketIOManager.sharedInstance.forumPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ForumPostsTableView.dequeueReusableCell(withIdentifier: "ForumCell") as! ForumTableViewCell
        cell.cellRow = indexPath.row
        cell.username.text = SocketIOManager.sharedInstance.forumPosts[indexPath.row].username
        cell.postText.text = SocketIOManager.sharedInstance.forumPosts[indexPath.row].postText
        cell.numComments.text = String(SocketIOManager.sharedInstance.forumPosts[indexPath.row].numComments)
        cell.numLikes.text = String(SocketIOManager.sharedInstance.forumPosts[indexPath.row].numLikes)
        if (SocketIOManager.sharedInstance.forumPosts[indexPath.row].didLikePost == "true"){
            print("It is true that the user liked this")
            print(SocketIOManager.sharedInstance.forumPosts[indexPath.row].postText)
            print(SocketIOManager.sharedInstance.forumPosts[indexPath.row].forumId)
            cell.likeBtn.imageView?.image = UIImage(named: "liked_btn")
        }
        cell.dateLabel.text = SocketIOManager.sharedInstance.forumPosts[indexPath.row].datePosted
        cell.userImg.image = SocketIOManager.sharedInstance.forumPosts[indexPath.row].image
        cell.userImg.layer.cornerRadius = cell.userImg.frame.height/2
                       cell.userImg.clipsToBounds = true
                       cell.userImg.layer.masksToBounds = true
        cell.delegate = self
            
            return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowPostComments"){
            let commentsVC = segue.destination as! PostCommentsViewController
            commentsVC.postId = SocketIOManager.sharedInstance.forumPosts[selectedBtnRow].forumId
            commentsVC.postArrIdx = selectedBtnRow
        }
    }
    

}

extension ForumViewController: ForumTableViewCellDelegate {
    func didTapLikeBtn(rowSelected: Int, cell: ForumTableViewCell) {
        print("curr user just liked a post with message ")
        print(SocketIOManager.sharedInstance.forumPosts[cell.cellRow].postText)
        print(" with forum id ")
        print(SocketIOManager.sharedInstance.forumPosts[cell.cellRow].forumId)
        var likeBtnAction: String = "like";
        if (SocketIOManager.sharedInstance.forumPosts[cell.cellRow].didLikePost == "true"){
            likeBtnAction = "unlike"
        }
        let posturl = SocketIOManager.sharedInstance.serverUrl + "/posts/likes"
        let info: [String:Any] = ["userId": SocketIOManager.sharedInstance.currUserObj.userId as Any, "postId": SocketIOManager.sharedInstance.forumPosts[cell.cellRow].forumId as Any, "likeAction": likeBtnAction]
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
            .responseString{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print(data)
                    if (data == "successful"){
                        print("action successful")
                        //change picture
                        if (likeBtnAction == "like"){
//                            cell.likeBtn.imageView?.image = UIImage(named: "heart.fill")
                                
                                    cell.likeBtn.imageView?.image = UIImage(named: "liked_btn")
                           
                            SocketIOManager.sharedInstance.forumPosts[cell.cellRow].numLikes = SocketIOManager.sharedInstance.forumPosts[cell.cellRow].numLikes + 1;
                            SocketIOManager.sharedInstance.forumPosts[cell.cellRow].didLikePost = "true"
                            self.ForumPostsTableView.reloadData()
                        }
                        else {
                            cell.likeBtn.imageView?.image = UIImage(named: "not_liked_btn")
                            SocketIOManager.sharedInstance.forumPosts[cell.cellRow].numLikes = SocketIOManager.sharedInstance.forumPosts[cell.cellRow].numLikes - 1;
                            SocketIOManager.sharedInstance.forumPosts[cell.cellRow].didLikePost = "false"
                            self.ForumPostsTableView.reloadData()
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
    
    func didTapCommentBtn(rowSelected: Int) {
        print("comment button tapped")
        self.selectedBtnRow = rowSelected
        self.performSegue(withIdentifier: "ShowPostComments", sender: self)
    }
    
    
}
