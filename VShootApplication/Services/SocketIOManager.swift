//
//  SocketIOManager.swift
//  VShootApplication
//
//  Created by Princess Candice on 10/11/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import SocketIO
import Alamofire

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    var resetAck: SocketAckEmitter?
    //var serverUrl = "https://serve-thevshoot.com";

    var serverUrl = "https://3df5b725.ngrok.io"
    var dataString: String = "";
    
    let manager = SocketManager(socketURL: URL(string: "https://serve-thevshoot.com")!, config: [.log(false), .forcePolling(false), .reconnects(false)])

    //var name: String?
    //var resetAck: SocketAckEmitter?
    var socket:SocketIOClient!
    var currUser: String = "";
    //var currUserObj:MainUser = MainUser()
    var currUserObj:User = User(username: "",imageUrl: "")
    var vsRequestor:String = "";
    var deviceToken = ""
    var purchases = Dictionary<String,Bool>()
    
    
    override init() {
        super.init()
        socket = manager.defaultSocket;
        print("initializing new socket")
        
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
    
    func sendMsg(group: String, message: String, date: String){
        var data = [String:Any]()
        data["username"] = SocketIOManager.sharedInstance.currUserObj.username
        //data["userImg"] = userImgUrl
        print("printing userID while sending new message")
        print((SocketIOManager.sharedInstance.currUserObj.userId))
        let id = Int(SocketIOManager.sharedInstance.currUserObj.userId)
        //print(Int("4"))
        print("printing converted id string")
        print(id as Any)
        data["userId"] = SocketIOManager.sharedInstance.currUserObj.userId
        data["group"] = group
        data["message"] = message
        data["date"] = date
        data["userImg"] = SocketIOManager.sharedInstance.currUserObj.imageUrl
        let socketData = data.socketRepresentation()
        socket.emit("newMessage", socketData)
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
        print("inside of take photo")
        var data = [String:Any]()
        data["flash"] = takePhoto
        let socketData = data.socketRepresentation()
        socket.emit("takephoto", socketData)
    }
    
    func establishConnection(username: String, fromLogin: Bool, completion: @escaping () -> ()) {
        print("printing socket status")
        print(socket.status)
        if(socket.status == SocketIOStatus.disconnected || socket.status == SocketIOStatus.notConnected){
            print("status is not connected")
            socket.connect()
            
            //clientEvent: .connect
            socket.once("connected") {data, ack in
                print("socket connected \(data)")
                print("printing socket status")
                print(self.socket.status)
                self.storeSocketRef(username: username, completion: {
                    print("stored socket reference")
                    if (fromLogin){
                        self.loadFriends(username: username, completion: {
                            print("friends loaded")
                            completion()
                        })
                    }
                    else {
                        completion()
                    }
                })
            }
        }
        else { //already connected so just store ref
            self.storeSocketRef(username: username, completion: {
                print("stored socket reference")
                if (fromLogin){
                    self.loadFriends(username: username, completion: {
                        print("friends loaded")
                        completion()
                    })
                }
                else {
                    completion()
                }
            })
        }

    }
    
    func loadFriends(username: String, completion: @escaping () -> ()) {
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
//                        self.loadGroups(username: username)
                        
                    }
                    else {
                        print("couldnt convert friends")
                    }
                    
                case .failure(let error):
                    print(error)
                }
                
                
        }
    }
    
    func loadGroups(username: String){
        let geturl2 = SocketIOManager.sharedInstance.serverUrl + "/groups/" + username
        let url = URL(string: geturl2)
        Alamofire.request(url!)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    if let groupDict = data as? [Dictionary<String,String>]{
                        print("successfully converted group response")
                        //change result to an array of friends like you did with the array of users in addFriend
                        SocketIOManager.sharedInstance.currUserObj.groups.removeAll()
                        for i in 0..<groupDict.count {
                            let newGroup = Group.init(name: groupDict[i]["name"]!, creator: groupDict[i]["creator"]!, description: groupDict[i]["description"]!)
                            SocketIOManager.sharedInstance.currUserObj.groups.append(newGroup)
                        }
                        print("done adding groups")
//                        self.getProfilePic(username: username)
                    }
                    else {
                        print("couldnt convert friends at 221")
                    }
                    
                    
                case .failure(let error):
                    print(error)
                }
                
        }
        self.getProfilePic(username: username)
    }
    
    func getProfilePic(username: String){
        //get profile pic url
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
                            SocketIOManager.sharedInstance.currUserObj.imageUrl = picurl
                            //download this pic
                            ImageService.getImage(withURL: picurl){ image in
                                //SocketIOManager.sharedInstance.currUserObj.image = image
                                self.currUserObj.image = image
                            }
                        }
                        else {
                            print("no profile pic")
                            SocketIOManager.sharedInstance.currUserObj.imageUrl = "none"
                            let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                                //SocketIOManager.sharedInstance.currUserObj.image = noProfileImage
                            self.currUserObj.image = noProfileImage
                        }
                    }
                    else {
                        print("cant convert")
                    }
                    
                    
                case .failure(let error):
                    
                    print(error)
                }
        }
        self.getUserId(username: username)
        self.storeDeviceToken()
    }
    
    func getUserId(username:String){
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
                    }
                    else {
                        print("cant convert userId")
                    }
                    
                case .failure(let error):
                    print("error")
                    print(error)
                    
                }
        }
    }
    
    func storeDeviceToken(){
        if(SocketIOManager.sharedInstance.deviceToken != ""){
            var posturl = SocketIOManager.sharedInstance.serverUrl + "/users/devicetokens"
            
            let info: [String:Any] = ["username": SocketIOManager.sharedInstance.currUserObj.username as Any, "token": SocketIOManager.sharedInstance.deviceToken as Any]
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
                        
                        
                    case .failure(let error):
                        print("failure")
                        print(error)
                        
                        
                    }
            }
        }
    }
    
    func storeSocketRef(username: String, completion: @escaping () -> ()) {
        print("trying to store reference")
        //currUserObj.username = username
        SocketIOManager.sharedInstance.currUserObj.username = username
        //self.currUser = username;
        SocketIOManager.sharedInstance.currUser = username
        //currUserObj.image = nil
        print("username passed to storeSocketRef " + username)
        socket.emit("join", username);
        completion()
        
    }
    
    
    func closeConnection() {
        print("disconnecting")
        socket.disconnect()
        //SocketIOManager.sharedInstance.socket.disconnect()
    }
}
