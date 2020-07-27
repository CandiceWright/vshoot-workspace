//
//  PostCommentsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 7/19/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class PostCommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    var comments:[PostComment] = []
    var dataString: String = "";
    var postId:Int = 0;
    var postArrIdx:Int = 0;
    
    @IBOutlet weak var CommentsTableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CommentsTableView.tableFooterView = UIView()
        CommentsTableView.rowHeight = UITableView.automaticDimension;
        CommentsTableView.estimatedRowHeight = 118.0
        self.CommentsTableView.isHidden = true
        getComments()
        self.commentTextView.delegate = self
        commentTextView.text = "Add a comment..."
        commentTextView.textColor = .lightGray
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.layer.borderWidth = 1.0
        commentBtn.isEnabled = false
        commentBtn.alpha = 0.1
        commentBtn.layer.cornerRadius = CGFloat(Float(4.0))
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewTapped), name: UITextView.textDidBeginEditingNotification, object: nil)
        
        self.hideKeyboard()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func postComment(_ sender: Any) {
        self.commentBtn.isEnabled = false;
        self.commentBtn.alpha = 0.1
        let commentText = self.commentTextView.text
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        let dateStr = formatter.string(from: date)
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/posts/comments"
        print("printing userId before posting")
        print(SocketIOManager.sharedInstance.currUserObj.userId)
        let info: [String:Any] = ["commentUser": SocketIOManager.sharedInstance.currUserObj.userId as Any, "commentText": commentText as Any, "commentDate": dateStr as Any, "postId": self.postId]
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
                        self.commentTextView.text = "Add a comment..."
                        self.commentTextView.textColor = .lightGray
                        let newComment = PostComment.init(commentText: commentText!, username: SocketIOManager.sharedInstance.currUserObj.username, userImageUrl: SocketIOManager.sharedInstance.currUserObj.imageUrl, commentDate: dateStr, isByCurrUser: "true")
                            
                        //self.posts.append(newPost)
                        self.comments.insert(newComment, at: 0)
                        SocketIOManager.sharedInstance.forumPosts[self.postArrIdx].numComments += 1
                        self.CommentsTableView.reloadData()
                    }
                    else {
                        self.commentBtn.isEnabled = true
                        self.commentBtn.alpha = 1.0
                        let alertController = UIAlertController(title: "Oops!", message:
                            "There was a problem saving your post. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in  }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                    self.commentBtn.isEnabled = true
                    self.commentBtn.alpha = 1.0
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
        }
    }
    
    func getComments(){
        print("user id in get posts" + SocketIOManager.sharedInstance.currUserObj.userId)
        var geturl = SocketIOManager.sharedInstance.serverUrl + "/posts/comments/"
        geturl += String(self.postId)
        geturl += "/" + SocketIOManager.sharedInstance.currUserObj.userId
        print(geturl)
                let url = URL(string: geturl)
                Alamofire.request(url!)
                    .validate(statusCode: 200..<201)
                    .responseJSON{ (response) in
                        switch response.result {
                        case .success(let data):
                            print(data)
                            self.CommentsTableView.isHidden = false
                            if let commentsDict = data as? [Dictionary<String,String>]{
                                for item in commentsDict.reversed() {
                                    let comment =
                                        PostComment.init(commentText: item["commentText"]!, username: item["username"]!, userImageUrl: item["userImgUrl"]!, commentDate: item["commentDate"]!, isByCurrUser: item["isByCurrUser"]!)
                                    if (item["userImgUrl"]! != "none"){
                                       ImageService.getImage(withURL: item["postUserProfilePic"]!, completion: {image in
                                                                                  print("got image")
                                        comment.userImage = image
                                                                              })
                                        
                                    }
                                    
                                    self.comments.append(comment)
                                    print()
                                }
                                self.CommentsTableView.reloadData()
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
    
    @objc func textChanged(sender: NSNotification) {
              if (self.commentTextView.hasText && commentTextView.text != "Add a comment..."){
                  commentBtn.isEnabled = true
                  commentBtn.alpha = 1.0
              }
              else {
                  commentBtn.isEnabled = false
                  commentBtn.alpha = 0.1
              }
          }
          
          @objc func textViewTapped(sender: NSNotification){
              if(self.commentTextView.text == "Add a comment..."){
                  commentTextView.text = ""
                  commentTextView.textColor = .black
              }
          }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CommentsTableView.dequeueReusableCell(withIdentifier: "CommentCell") as! PostCommentTableViewCell
        cell.cellRow = indexPath.row
        cell.usernameLabel.text = comments[indexPath.row].username
        cell.commentTxt.text = comments[indexPath.row].commentText
        
        cell.dateLabel.text = comments[indexPath.row].commentDate
        cell.userImg.image = comments[indexPath.row].userImage
        cell.userImg.layer.cornerRadius = cell.userImg.frame.height/2
                       cell.userImg.clipsToBounds = true
                       cell.userImg.layer.masksToBounds = true
            
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
