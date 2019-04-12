//
//  NewVSInfoPopupViewController.swift
//  VShootApplication
//
//  Created by Princess Candice on 10/8/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import SocketIO
import iOSDropDown
import SwiftSpinner
import Alamofire


class NewVSInfoPopupViewController: UIViewController {

    @IBOutlet weak var VSName: UITextField!
    @IBOutlet weak var myRoleDropdown: DropDown!
    @IBOutlet weak var selectDropDown: DropDown!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    var role:String = ""
    var username:String = ""
    var vshootId: NSInteger = 0
    var accessToken:String = ""
    var roomName:String = ""
    var otherUser:String = ""
    var friends:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        startBtn.isEnabled = false
        startBtn.alpha = 0.5
        
        // The list of array to display. Can be changed dynamically
        myRoleDropdown.optionArray = ["votographer", "vmodel"]
        //Its Id Values and its optional
        myRoleDropdown.optionIds = [1,2]
        myRoleDropdown.isSearchEnable = false
        // The the Closure returns Selected Index and String
        myRoleDropdown.didSelect{(selectedText , index ,id) in
            self.role = selectedText
            print(self.role)
            if (self.otherUser != ""){
                self.startBtn.isEnabled = true
                self.startBtn.alpha = 1.0
            }
            
        }
        
        print(friends)
        selectDropDown.optionArray = friends
        //selectDropDown.optionIds = [1]
        selectDropDown.didSelect{(selectedText, index, id) in
            self.otherUser = selectedText
            if (self.role != ""){
                self.startBtn.isEnabled = true
                self.startBtn.alpha = 1.0
            }
        }
        
        selectDropDown.listWillAppear {
        print("hiding")
        self.cancelBtn.isHidden = true
        //self.dismissKeyboard()
        }
                selectDropDown.listDidDisappear {
                    print("unhiding")
                    self.cancelBtn.isHidden = false
                }
        selectDropDown.listWillDisappear {
        print("unhiding")
        self.cancelBtn.isHidden = false
        }
        
        self.username = SocketIOManager.sharedInstance.currUser
        //have the socket listen for vshoot accepted event
        SocketIOManager.sharedInstance.socket.on("vshootCanStart") { dataArray, ack in
            print(dataArray)
            let data = dataArray[0] as! Dictionary<String,AnyObject>
            self.vshootId = data["vshootId"] as! NSInteger
            print("vsID: ")
            print(self.vshootId)
            print("notified that vshot can start")
            self.accessToken = data["accessToken"] as! String
            self.roomName = data["roomName"] as! String
            //segue to a new video view controller, must have two different view controllers
            if (self.role == "vmodel"){
                //just show view controller that has video, soon allow user to access their albums
                self.performSegue(withIdentifier: "showVmodelVideoView", sender: self)
            }
            else {
                //show a view controller with video and camera capture button
                self.performSegue(withIdentifier: "showVotographerVideoViewFromNewVSScreen", sender: self)
            }
        }
        
        SocketIOManager.sharedInstance.socket.on("UserDeclined"){ dataResponse, ack in
            //this means the user has declined
            SwiftSpinner.hide()
            let alertController = UIAlertController(title: "Sorry, the user has declined the request. Please try again later.", message:
                nil, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                self.performSegue(withIdentifier: "backToTBFromVSRequest", sender: self) }))
            
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        SocketIOManager.sharedInstance.socket.on("UserOffline"){ dataResponse, ack in
            //this means the user has declined
            SwiftSpinner.hide()
            let alertController = UIAlertController(title: "User Offline", message:
                self.otherUser + " is not online or does not have the app open right now. Choose another user or notify " + self.otherUser + " to be logged in with the app open!", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                 }))
            
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        SocketIOManager.sharedInstance.socket.on("OnlyVotographriends"){dataResponse, ack in
            let data = dataResponse[0] as! String
            print(data)
            SwiftSpinner.hide()
            let alertController = UIAlertController(title: "Not Mutual Vriends.", message:
                data, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
            }))
            
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                //keyboardSize.height
                self.view.frame.origin.y -= 100
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
//    func setupKeyboardDismissRecognizer(){
//        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
//            target: self,
//            action: #selector(self.dismissKeyboard))
//
//        self.view.addGestureRecognizer(tapRecognizer)
//    }
//
//    @objc func dismissKeyboard()
//    {
//        view.endEditing(true)
//    }
    
    @IBAction func closeVSInfoWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func startVS(_ sender: Any) {
        //let receiver = selectDropDown.text!
        let receiver = self.otherUser
        let sender = username //me
        //let senderRole = myRole.text!
        let senderRole = self.role //my role
        SocketIOManager.sharedInstance.initiateNewVshoot(receiver: receiver, sender: sender, senderRole: senderRole)
        //socket.connect()
        //emit a message to the socket with who you want to start shoot with
        //use spinner cocoapod to show client they are waiting for  connection
        
       
        self.showSpinner(receiver: receiver)
        
        
        
    }
    
    func showSpinner(receiver:String){
        SwiftSpinner.show("Waiting for " + receiver + "...").addTapHandler({
            SwiftSpinner.hide()
            let alertController = UIAlertController(title: "Are you ", message: "Are you sure you want to cancel?", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default,handler: {(action) in
                //SwiftSpinner.hide()
                SocketIOManager.sharedInstance.cancelVSRequest()
                
                //let other user know that the request has been cancelled
            }))
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default,handler: {(action) in
                self.showSpinner(receiver: receiver)
                
                
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }, subtitle: "Tap screen to cancel Request!")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showVmodelVideoView"){
            let destinationController = segue.destination as! VmodelViewController
            destinationController.accessToken = self.accessToken
            destinationController.vshootId = self.vshootId
            destinationController.roomName = self.roomName
        }
        else if (segue.identifier == "showVotographerVideoViewFromNewVSScreen"){
            let destinationController = segue.destination as! VotographerViewController
            destinationController.accessToken = self.accessToken
            destinationController.vshootId = self.vshootId
            destinationController.roomName = self.roomName
        }
        else if (segue.identifier == "backToTBFromVSRequest"){
            let barViewControllers = segue.destination as! UITabBarController
            barViewControllers.selectedIndex = 1
            
            
            
        }
        
    }
    

}


