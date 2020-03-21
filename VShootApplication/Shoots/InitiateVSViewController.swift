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
        //UserDefaults.standard.removeObject(forKey: "freeTrialAvailable")
        
        if(UserDefaults.standard.object(forKey: "freeTrialAvailable") == nil){
            startVSButton.setTitle("Try Your First VShoot Free!", for: UIControl.State.normal)
            
        }
        self.startVSButton.isHidden = true
        getFriends(completion: {
            self.startVSButton.isHidden = false
        })
        // Do any additional setup after loading the view.
        
        self.startVSButton.layer.cornerRadius = CGFloat(Float(10.0))
        SocketIOManager.sharedInstance.socket.removeAllHandlers()
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
    
    @IBAction func showVSGuide(_ sender: Any) {
        performSegue(withIdentifier: "toAboutVS", sender: self)
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
                                }
                                print("done adding friends")
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
            
        else if (segue.identifier == "newVSPopup") {
            let destinationVC:NewVSInfoPopupViewController = segue.destination as! NewVSInfoPopupViewController
            print("username before I segue " + username)
            //destinationVC.username = username
            destinationVC.username = SocketIOManager.sharedInstance.currUser
            destinationVC.friends = self.friends
        }
    }
    

}
