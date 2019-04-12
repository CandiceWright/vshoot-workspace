//
//  ManageFriendshipsViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 12/14/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class ManageFriendshipsViewController: UIViewController {

    @IBOutlet weak var ManageFriendView: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var optionBtn: UIButton!
    //var friends = SocketIOManager.sharedInstance.currUserObj.friends
    var fromFriendsPage:Bool = false
    var currUser:String = ""
    var userImg:UIImage = UIImage()
    var opBtnTxt:String = ""
    var dataString: String = "";
    var Users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        username.text = currUser
        userImage.image = userImg
        optionBtn.setTitle(opBtnTxt, for: UIControl.State.normal)
        if (opBtnTxt == "Remove"){
            optionBtn.backgroundColor = UIColor.black
        }
        
        self.ManageFriendView.layer.cornerRadius = CGFloat(Float(15.0))
        self.optionBtn.layer.cornerRadius = CGFloat(Float(5.0))
        self.userImage.layer.cornerRadius = self.userImage.frame.height/2
        self.userImage.clipsToBounds = true
        
        if (username.text == SocketIOManager.sharedInstance.currUser){
            self.optionBtn.isHidden = true
        }
    }
    
    @IBAction func manageFriendship(_ sender: Any) {
        self.optionBtn.isEnabled = false
        //first check tto see what the text of the button is
        if (optionBtn.currentTitle == "Add"){
            //make a request to add friend
            let geturl = SocketIOManager.sharedInstance.serverUrl + "/addFriends"
            //let currU = SocketIOManager.sharedInstance.currUser
            let currU = SocketIOManager.sharedInstance.currUserObj.username
            let addedUsername = username.text
            var addedU:User = User(username: "",imageUrl: "")
            for i in 0..<Users.count{
                if (Users[i].username == addedUsername){
                    addedU = Users[i]
                }
            }
            
            print("current logged in user: " + currU)
            let info: [String:Any] = ["currentUser": currU ,"addedFriend": username.text as Any]
            do {
                let data = try JSONSerialization.data(withJSONObject: info, options: [])
                dataString = String(data: data, encoding: .utf8)!
            } catch {
                print("error")
            }
            
            //let url = URL(string: geturl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            let url = URL(string: geturl);
            
            Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
                .validate(statusCode: 200..<201)
                .responseString{ (response) in
                    print(response)
                    switch response.result {
                        case .success(let data):
                            print(data)
                            print("friends count before adding")
                            print(SocketIOManager.sharedInstance.currUserObj.friends.count)
                            SocketIOManager.sharedInstance.currUserObj.friends.append(addedU);
                            print("friends count after adding")
                            print(SocketIOManager.sharedInstance.currUserObj.friends.count)
                            
                            self.optionBtn.setTitle("Remove", for: UIControl.State.normal)
                   
                    self.optionBtn.backgroundColor = UIColor.black
                        self.optionBtn.isEnabled = true
                        
                    case .failure(let error):
                            print(error)
                            self.optionBtn.isEnabled = true
                            let alertController = UIAlertController(title: "Sorry!", message:
                                "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                            
                            self.present(alertController, animated: true, completion: nil)
                    }
            }
        }
        else {
            //make request to remove friend
            let geturl = SocketIOManager.sharedInstance.serverUrl + "/deleteFriend"
            //let currU = SocketIOManager.sharedInstance.currUser
            let currU = SocketIOManager.sharedInstance.currUserObj.username
            let removedUsername = username.text
            var removedUserIndex = -1
            for i in 0..<SocketIOManager.sharedInstance.currUserObj.friends.count{
                if (SocketIOManager.sharedInstance.currUserObj.friends[i].username == removedUsername){
                    removedUserIndex = i
                }
            }
            print("current logged in user: " + currU)
            let info: [String:Any] = ["currentUser": currU ,"deletedFriend": username.text as Any]
            do {
                let data = try JSONSerialization.data(withJSONObject: info, options: [])
                dataString = String(data: data, encoding: .utf8)!
            } catch {
                print("error")
            }
            
            //let url = URL(string: geturl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            let url = URL(string: geturl);
            
            Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
                .validate(statusCode: 200..<201)
                .responseString{ (response) in
                    print(response)
                    switch response.result {
                    case .success(let data):
                        print(data)
                        print("friends count before removing")
                        print(SocketIOManager.sharedInstance.currUserObj.friends.count)
                        SocketIOManager.sharedInstance.currUserObj.friends.remove(at: removedUserIndex);
                        print("friends count after removing")
                        print(SocketIOManager.sharedInstance.currUserObj.friends.count)
                        
                        //change button color to black and text to remove
                        self.optionBtn.setTitle("Add", for: UIControl.State.normal)
                        let greenColor = UIColor(rgb: 0x31D283)
                        self.optionBtn.backgroundColor = greenColor
                        self.optionBtn.isEnabled = true
                    case .failure(let error):
                        print(error)
                        self.optionBtn.isEnabled = true
                        let alertController = UIAlertController(title: "Sorry!", message:
                            "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
            }
        }
    }
    
    @IBAction func closePopup(_ sender: Any) {
        if (fromFriendsPage){
            ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
        }
        else {
           dismiss(animated: true, completion: nil)
        }
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

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
