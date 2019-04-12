//
//  VSViewController.swift
//  VShootApplication
//
//  Created by Princess Candice on 10/7/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import SocketIO

class VSViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var VSTableView: UITableView!
    var vshoots:Array<Any> = []
    var username:String = ""
    var vshootId: NSInteger = 0
    var vshootRequestor: String = ""
    var myRole: String = ""
    var accessToken:String = ""
    var roomName:String = ""
//    let manager = SocketManager(socketURL: URL(string: "http://localhost:7343")!, config: [.log(true), .compress])
//    var socket:SocketIOClient!
    @IBAction func startNewVS(_ sender: Any) {
        //maybe instead just make the cells clickable
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vshoots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = VSTableView.dequeueReusableCell(withIdentifier: "VSCell") as! VSTableViewCell
        //once you actuall have a list of vshoots, you should replace VSName with each VS name from array
        cell.VSName.text = "hi"
        //need to add image view info
        return cell
    }
    
    func acceptVSRequest() {
        //should atleast send my username and the vsID I am accepting
        SocketIOManager.sharedInstance.sendUserAcceptance(vsID: vshootId, username: username)
    }
    override func viewWillAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.establishConnection()
    }
    
    override func viewDidLoad() {
        //self.socket = manager.defaultSocket;
       // self.socket.connect();
        super.viewDidLoad()
       print("username in VS tab bar controller" + self.username)
//        SocketIOManager.sharedInstance.storeSocketRef(username: username);

        // Do any additional setup after loading the view.
        
        SocketIOManager.sharedInstance.storeSocketRef(username: self.username);
        
        SocketIOManager.sharedInstance.socket.on("newVSRequest") { dataArray, ack in
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
            alertController.addAction(UIAlertAction(title: "Decline", style: UIAlertAction.Style.default,handler: nil))
            
                        self.present(alertController, animated: true, completion: nil)
        }
        
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
                 self.performSegue(withIdentifier: "segueToVmodelVideoViewFromVSView", sender: self)
            }
            else {
                //show a view controller with video and camera capture button
                 self.performSegue(withIdentifier: "segueToVotographerVideoViewFromVSView", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // MARK: - Navigation
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
        
        else {
            let destinationVC:NewVSInfoPopupViewController = segue.destination as! NewVSInfoPopupViewController
            print("username before I segue " + username)
            destinationVC.username = username
        }
    }
    
    

}
