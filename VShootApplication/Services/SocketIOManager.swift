//
//  SocketIOManager.swift
//  VShootApplication
//
//  Created by Princess Candice on 10/11/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    var serverUrl = "https://1e4ecea3.ngrok.io";
    let manager = SocketManager(socketURL: URL(string: "https://1e4ecea3.ngrok.io")!, config: [.log(true), .compress])
    var socket:SocketIOClient!
    var currUser: String = "";
    var currUserObj:MainUser = MainUser()
    var vsRequestor:String = "";
    
    
    override init() {
        super.init()
        self.socket = manager.defaultSocket;
        socket.on("test") { dataArray, ack in
            print(dataArray)
        }
        
//        socket.on("newVSRequest") { dataArray, ack in
//            figure out how this notification center works
//            NotificationCenter.default
//                .post(name: Notification.Name(rawValue: "newVshootRequestNotification"), object: dataArray[0] as? [String: AnyObject])
//            let alertController = UIAlertController(title: "iOScreator", message:
//                "Hello, world!", preferredStyle: UIAlertControllerStyle.alert)
//            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
//
//            self.present(alertController, animated: true, completion: nil)
//        }
        
        //add more .on listeners to get info from server
        
    }
    
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
    }
    
    func sendUserAcceptance(vsID: NSInteger, username: String){
        var data = [String:Any]()
        data["vsID"] = vsID;
        data["username"] = username;
        let socketData = data.socketRepresentation()
        socket.emit("acceptVSRequest", socketData)
    }
    
    func sendUserDcline(vsID: NSInteger, username: String){
        var data = [String:Any]()
        data["vsID"] = vsID;
        data["username"] = username;
        let socketData = data.socketRepresentation()
        socket.emit("declineVSRequest", socketData)
    }
    
    func initiateNewVshoot(receiver: String, sender: String, senderRole: String) {
        let today : String!
        today = getTodayString()
        var data = [String:Any]()
        data["sender"] = sender
        data["senderRole"] = senderRole
        data["receiver"] = receiver
        data["date"] = today
        let socketData = data.socketRepresentation()
        socket.emit("startVshoot", socketData)
    }
    
    func cancelVSRequest(){
        socket.emit("cancelRequest")
    }
    
    func endVShoot(vsId: Int, endInitiator: String){
        var data = [String:Any]()
        data["vsID"] = vsId
        data["initiator"] = endInitiator
        let socketData = data.socketRepresentation()
        socket.emit("endVShoot", socketData)
    }
    
    func triggerPhotoCapture(takePhoto:Bool){
        var data = [String:Any]()
        data["flash"] = takePhoto
        let socketData = data.socketRepresentation()
        socket.emit("takephoto", socketData)
    }
    
    func establishConnection() {
        socket.connect()
        //should emit the join message right after
    }
    
    func storeSocketRef(username: String) {
        print("trying to store reference")
        currUserObj.username = username
        self.currUser = username;
        currUserObj.image = nil
        print("username passed to storeSocketRef " + username)
        socket.emit("join", username);
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
}
