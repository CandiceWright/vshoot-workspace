//
//  VSShootEntranceViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/21/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class VSShootEntranceViewController: UIViewController {
    
    var vshoots:Array<Any> = []
    var username:String = ""
    var vshootId: NSInteger = 0
    var vshootRequestor: String = ""
    var myRole: String = ""
    var accessToken:String = ""
    var roomName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //have the socket listen for vshoot accepted event
        SocketIOManager.sharedInstance.socket.on("vshootCanStart") { dataArray, ack in
            print(dataArray)
            let data = dataArray[0] as! Dictionary<String,AnyObject>
            self.vshootId = data["vshootId"] as! NSInteger
            print("vsID: ")
            print(self.vshootId)
            self.accessToken = data["accessToken"] as! String
            self.roomName = data["roomName"] as! String
            self.myRole = data["myRole"] as! String
            print("my role before showing video view: " + self.myRole);
            if (self.myRole == "vmodel"){
                //just show view controller that has video, soon allow user to access their albums
                self.performSegue(withIdentifier: "segueToVmodelVideoViewFromVSEntrance", sender: self)
            }
            else {
                //show a view controller with video and camera capture button
                self.performSegue(withIdentifier: "segueToVotographerVideoViewFromVSEntrance", sender: self)
            }
        }
        
        SocketIOManager.sharedInstance.socket.on("VSRequestActionFailed"){
            dataArray, ack in
            let alertController = UIAlertController(title: "Cancelled", message:
                "The vshoot has already been cancelled by the other user.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                self.performSegue(withIdentifier: "cancelledRequestSegue", sender: self)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToVmodelVideoViewFromVSEntrance"){
            let destinationController = segue.destination as! VmodelViewController
            destinationController.accessToken = self.accessToken
            destinationController.vshootId = self.vshootId
            destinationController.roomName = self.roomName
        }
        else if (segue.identifier == "segueToVotographerVideoViewFromVSEntrance"){
            let destinationController = segue.destination as! VotographerViewController
            destinationController.accessToken = self.accessToken
            destinationController.vshootId = self.vshootId
            destinationController.roomName = self.roomName
        }
    }
 

}
