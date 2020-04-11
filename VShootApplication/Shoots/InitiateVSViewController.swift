//
//  InitiateVSViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 12/27/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire
import SocketIO
import SwiftSpinner
import FirebaseAuth

class InitiateVSViewController: UIViewController {

    var vshoots:Array<Any> = []
    var username:String = ""
    var vshootId: NSInteger = 0
    var vshootRequestor: String = ""
    var myRole: String = ""
    var accessToken:String = ""
    var roomName:String = ""
    var friends:Array<String> = []
    
    @IBOutlet weak var startVSButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startVSButton.layer.cornerRadius = CGFloat(Float(10.0))
        SocketIOManager.sharedInstance.socket.removeAllHandlers()
                
        // Do any additional setup after loading the view.
        
        SocketIOManager.sharedInstance.socket.on("newVSRequest") { dataArray, ack in
            print("new vs request")
            print("dataArray: ")
            print(dataArray)
            let data = dataArray[0] as! Dictionary<String,AnyObject>
            print("data: ")
            print(data)
            self.vshootId = data["vshootId"] as! NSInteger
            print("vsID: ")
            print(self.vshootId)
            self.vshootRequestor = data["vshootRequestor"] as! String
            print("vsRequestor: " + self.vshootRequestor)
            self.myRole = data["receiverRole"] as! String
            print("myRole: " + self.myRole)
            
            
            let alertController = UIAlertController(title: "New Vshoot Request from", message:
                self.vshootRequestor, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Accept", style: UIAlertAction.Style.default,handler: {(action) in
                self.acceptVSRequest() }))
            alertController.addAction(UIAlertAction(title: "Decline", style: UIAlertAction.Style.default,handler: {(action) in self.declineVSRequest() }))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        SocketIOManager.sharedInstance.socket.on("VSRequestActionFailed"){
            dataArray, ack in
            let alertController = UIAlertController(title: "Cancelled", message:
                "The vshoot has already been cancelled by the other user.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get friends and profile pic
        if (!SocketIOManager.sharedInstance.loadedFriends){
            SwiftSpinner.show("Loading profile", animated: true)
            print("need to get friends")
            self.startVSButton.isHidden = true
            getFriends(completion: {
                self.startVSButton.isHidden = false
                SocketIOManager.sharedInstance.loadedFriends = true
                self.getProfilePic(completion: {
                    SwiftSpinner.hide()
                })
            })
        }
        
        //get id
        if( SocketIOManager.sharedInstance.currUserObj.userId == ""){
            if (UserDefaults.standard.string(forKey: "userId") == nil){
                self.getUserId(username: self.username, completion: {
                })
            }
            else {
                let id = UserDefaults.standard.string(forKey: "userId")
                SocketIOManager.sharedInstance.currUserObj.userId = id!
            }
        }
        
        if (SocketIOManager.sharedInstance.needToConnectSocket){
            SocketIOManager.sharedInstance.establishConnection(username: SocketIOManager.sharedInstance.currUserObj.username, fromLogin: true, completion: {
                print("connection established")
                SocketIOManager.sharedInstance.needToReconnectOnBecomeActive = true
                SocketIOManager.sharedInstance.needToConnectSocket = false
            })
        }
        
    }
    
    @IBAction func showVSGuide(_ sender: Any) {
        performSegue(withIdentifier: "toAboutVS", sender: self)
    }
    
    @IBAction func ToVShootOps(_ sender: Any) {
        performSegue(withIdentifier: "ToVSForm", sender: self)
    }
    
    
    func getFriends(completion: @escaping () -> ()){
        let currUser = SocketIOManager.sharedInstance.currUser
                //let currUser = currUserObj.username
                print("getting friends for " + currUser)
                let geturl = SocketIOManager.sharedInstance.serverUrl + "/friends/" + currUser
                let url = URL(string: geturl)
                Alamofire.request(url!)
                    .responseJSON{ (response) in
                        switch response.result {
                        case .success(let data):
                            print(data)
                            if let friendDict = data as? [Dictionary<String,String>]{
                                print("successfully converted friend response")
                                //change result to an array of friends like you did with the array of users in addFriend
                                SocketIOManager.sharedInstance.currUserObj.friends.removeAll()
                                for i in 0..<friendDict.count {
                                    let newUser = User.init(username: friendDict[i]["username"]!, imageUrl: friendDict[i]["pic"]!)
                                    self.friends.append(friendDict[i]["username"]!)
                                    SocketIOManager.sharedInstance.currUserObj.friends.append(newUser)
                                    SocketIOManager.sharedInstance.friendStrings.append(friendDict[i]["username"]!)
                                }
                                print("done adding friends")
                                SocketIOManager.sharedInstance.loadedFriends = true
                                print(SocketIOManager.sharedInstance.currUserObj.friends.count)
                                //now get vsPreference
                                let geturl2 = SocketIOManager.sharedInstance.serverUrl + "/user/preference/" + currUser
                                let url = URL(string: geturl2)
                                Alamofire.request(url!)
                                    .responseString{ (response) in
                                        switch response.result {
                                        case .success(let data):
                                            print(data)
                                            if (data != "failed to get preference"){
                                                print("successfully got preference")
                                                SocketIOManager.sharedInstance.currUserObj.vsPreference = data
                                                print(SocketIOManager.sharedInstance.currUserObj.vsPreference)
                            completion()
                                            }
                                            else {
                                                print("could not convert vs preference")
                                            }
                                            
                                            
                                        case .failure(let error):
                                            print(error)
                                        }
                                }
                                
                            }
                            else {
                                print("couldnt convert friends")
                            }
                            
                        case .failure(let error):
                            print(error)
                        }
                        
                        
                }
    }
    
    func getProfilePic(completion: @escaping () -> ()){
        if (!SocketIOManager.sharedInstance.loadedProfilePic){
                   //needs to get image but first should check if the url is in userdefaults
                   print("need to get image")
                   if(UserDefaults.standard.string(forKey: "profilepicurl") != nil){
                    print("url saved in defaults")
                       let picurl = UserDefaults.standard.string(forKey: "profilepicurl")
                       if (picurl != "no profile pic"){
                           //download this pic
                           ImageService.getImage(withURL: picurl!){ image in
                            SocketIOManager.sharedInstance.currUserObj.imageUrl = picurl!
                            SocketIOManager.sharedInstance.currUserObj.image = image
                               UserDefaults.standard.set(picurl, forKey: "profilepicurl")
                            SocketIOManager.sharedInstance.loadedProfilePic = true
                            completion()
                           }
                       }
                       else {
                           print("no profile pic")
                            print(picurl)
                           let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                        SocketIOManager.sharedInstance.currUserObj.imageUrl = "no profile pic"
                        SocketIOManager.sharedInstance.currUserObj.image = noProfileImage
                           UserDefaults.standard.set("no profile pic", forKey: "profilepicurl")
                        SocketIOManager.sharedInstance.loadedProfilePic = true
                        completion()
                       }
                   }
                   else {
                       //first time fetching the photo so need to get it from Server
                    let geturl2 = SocketIOManager.sharedInstance.serverUrl + "/user/profilePic/" + SocketIOManager.sharedInstance.currUserObj.username
                       let url2 = URL(string: geturl2)
                       Alamofire.request(url2!)
                           .validate(statusCode: 200..<201)
                           .responseString{ (response) in
                               print(response)
                               switch response.result {
                               case .success(let data):
                                   print("successfully got image url")
                                   print(data)
                                   if let picurl = data as? String {
                                       print(picurl)
                                       if (picurl != "no profile pic"){
                                           //download this pic
                                           ImageService.getImage(withURL: picurl){ image in
                                            SocketIOManager.sharedInstance.currUserObj.imageUrl = picurl
                                            SocketIOManager.sharedInstance.currUserObj.image = image
                                               UserDefaults.standard.set(picurl, forKey: "profilepicurl")
                                            SocketIOManager.sharedInstance.loadedProfilePic = true
                                            completion()
                                           }
                                       }
                                       else {
                                           print("no profile pic")
                                           let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                                        SocketIOManager.sharedInstance.currUserObj.imageUrl = "no profile pic"
                                        SocketIOManager.sharedInstance.currUserObj.image = noProfileImage
                                           UserDefaults.standard.set("no profile pic", forKey: "profilepicurl")
                                        SocketIOManager.sharedInstance.loadedProfilePic = true
                                        completion()
                                       }
                                   }
                                   else {
                                       print("cant convert")
                                       let alertController = UIAlertController(title: "Sorry!", message:
                                           "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                                       alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                                       
                                       self.present(alertController, animated: true, completion: nil)
                                   }
                                   
                                   
                               case .failure(let error):
                                   
                                   print(error)
                                   let alertController = UIAlertController(title: "Sorry!", message:
                                       "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                                   alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                                   
                                   self.present(alertController, animated: true, completion: nil)
                               }
                       }
                   }
                   

               }
    }
    
    func getUserId(username:String, completion: @escaping () -> ()){
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/user/" + username
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .validate(statusCode: 200..<201)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    //if let userId = data as? String {
                    if let idJson = data as? Dictionary<String,Int> {
                        print("printing userid")
                        print(idJson["userId"])
                        SocketIOManager.sharedInstance.currUserObj.userId = String(idJson["userId"]!)
                        print(SocketIOManager.sharedInstance.currUserObj.userId)
                        print("successfully got userid")
                         UserDefaults.standard.set(SocketIOManager.sharedInstance.currUserObj.userId, forKey: "userId")
                        completion()
                    }
                    else {
                        print("cant convert userId")
                        completion()
                    }
                    
                case .failure(let error):
                    print("error")
                    print(error)
                    completion()
                    
                }
        }
    }
    
    
    func acceptVSRequest() {
        //should atleast send my username and the vsID I am accepting
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "VShootEntrance") as! VSShootEntranceViewController
        self.present(newViewController, animated: true, completion: nil)
        SocketIOManager.sharedInstance.sendUserAcceptance(vsID: vshootId, username: SocketIOManager.sharedInstance.currUser)
        
    }
    
    func declineVSRequest() {
        SocketIOManager.sharedInstance.sendUserDcline(vsID: vshootId, username: SocketIOManager.sharedInstance.currUser)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "segueToVmodelVideoViewFromVSView"){
            let destinationController = segue.destination as! VmodelViewController
            destinationController.accessToken = self.accessToken
            destinationController.vshootId = self.vshootId
            destinationController.roomName = self.roomName
        }
        else if (segue.identifier == "segueToVotographerVideoViewFromVSView"){
            let destinationController = segue.destination as! VotographerViewController
            destinationController.accessToken = self.accessToken
            destinationController.vshootId = self.vshootId
            destinationController.roomName = self.roomName
        }
            
        else if (segue.identifier == "ToVSForm") {
            let destinationVC:NewVSInfoPopupViewController = segue.destination as! NewVSInfoPopupViewController
            print("username before I segue " + username)
            //destinationVC.username = username
            //destinationVC.username = SocketIOManager.sharedInstance.currUser
            //destinationVC.friends = self.friends
        }
    }
    

}
