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
        if(UserDefaults.standard.object(forKey: "freeTrialAvailable") == nil){
            startVSButton.setTitle("Try Your First VShoot Free!", for: UIControl.State.normal)
            
        }
        print("printing friends count")
        print(SocketIOManager.sharedInstance.currUserObj.friends.count)
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
    
    @IBAction func startVS(_ sender: Any) {
        if (SocketIOManager.sharedInstance.purchases.keys.contains("com.thevshoot.vshootapp.vshootfuncpurchase") || UserDefaults.standard.object(forKey: "freeTrialAvailable") == nil){ //it is purchased
            //populate friends list
            self.friends.removeAll()
            let currUser = SocketIOManager.sharedInstance.currUser
            let geturl = SocketIOManager.sharedInstance.serverUrl + "/friends/" + currUser
            let url = URL(string: geturl)
            Alamofire.request(url!)
                .validate(statusCode: 200..<201)
                .responseJSON{ (response) in
                    switch response.result {
                    case .success(let data):
                        print(data)
                        if let friendDict = data as? [Dictionary<String,String>]{
                            print("successfully converted friend response")
                            //change result to an array of friends like you did with the array of users in addFriend
                            for i in 0..<friendDict.count {
                                self.friends.append(friendDict[i]["username"]!)
                            }
                            if (self.friends.count == 0){ //no friends yet
                                let alertController = UIAlertController(title: "It looks like you haven't added any friends to have VShoots with yet. ", message:
                                    nil, preferredStyle: UIAlertController.Style.alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                                }))
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                            else {
                                print("about to segue to form")
                                print(self.friends)
                                self.performSegue(withIdentifier: "newVSPopup", sender: self)
                            }
                        }
                        else {
                            print("couldnt convert friends")
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
        else {
            //they have already used their free trial so they need to pay
            self.performSegue(withIdentifier: "VSPurchaseWindowSegue", sender: self)
            
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
