//
//  ProfileViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/6/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseStorage
import UserNotifications

class ProfileViewController: UIViewController {
    
    var imagePicker:UIImagePickerController!
    var userId:String!
    var currUser:String!
    var downloadUrl:String = ""
    var vshootId: NSInteger = 0
    var vshootRequestor: String = ""
    var myRole: String = ""
    var accessToken:String = ""
    var roomName:String = ""
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("I am in view did load")
        print("printing curruser in profile")
        print(self.currUser)
        
        self.username.text = SocketIOManager.sharedInstance.currUserObj.username
        
        //we should already have an image
        //self.getProfilePic()
        
        self.profilePic.layer.masksToBounds = false
        self.profilePic.layer.cornerRadius = self.profilePic.frame.width/2
        self.profilePic.clipsToBounds = true
        print(self.profilePic.frame.height);
        print(self.profilePic.frame.width);
        
        self.profilePic.image = SocketIOManager.sharedInstance.currUserObj.image
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshlbl(notification:)), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
        
        //allow image to be clickable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePic))
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(tapGesture)
        
        
//        self.currUser = SocketIOManager.sharedInstance.currUser
        
    }
    
    
    @IBAction func changeUsername(_ sender: Any) {
        
    }
    
    @IBAction func changeemail(_ sender: Any) {
    }
    
    @IBAction func close(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        print("logging out")
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/logout"
        let info: [String:Any] = ["username": SocketIOManager.sharedInstance.currUserObj.username as Any]
        
        let url = URL(string: posturl);
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<201)
            .responseString{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print(data)
                        print("logout successful")
                    SocketIOManager.sharedInstance.currUser = ""
                    SocketIOManager.sharedInstance.currUserObj.username = ""
                    SocketIOManager.sharedInstance.currUserObj.imageUrl = ""
                    SocketIOManager.sharedInstance.currUserObj.friends.removeAll()
                    SocketIOManager.sharedInstance.currUserObj.groups.removeAll()
                    
                    SocketIOManager.sharedInstance.currUserObj.image = nil
                    SocketIOManager.sharedInstance.currUserObj.userId = ""
                    SocketIOManager.sharedInstance.loadedFriends = false
                    SocketIOManager.sharedInstance.loadedGroups = false
                    SocketIOManager.sharedInstance.loadedProfilePic = false
                    SocketIOManager.sharedInstance.needToReconnectOnBecomeActive = false
                    SocketIOManager.sharedInstance.needToConnectSocket = true
                    SocketIOManager.sharedInstance.friendStrings.removeAll()
                    
                    //disconnect socket
                    SocketIOManager.sharedInstance.socket.removeAllHandlers()
                    SocketIOManager.sharedInstance.socket.disconnect()
                    
                    //clear user defaults
                    UserDefaults.standard.set("", forKey: "username")
                    UserDefaults.standard.set(false, forKey: "UserLoggedIn")
                    
                    UserDefaults.standard.set(nil, forKey: "profilepicurl")
                    UserDefaults.standard.set(nil, forKey: "userId")
                        self.performSegue(withIdentifier: "logoutSegue", sender: self)
                        
                    
                    
                    
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
    
    @objc func changeProfilePic(){
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @objc func refreshlbl(notification: NSNotification) {
        
        username.text = SocketIOManager.sharedInstance.currUser  //Update your label here.
    }

    
    
    @objc func savePicUrltoDB(url:String){
        var geturl = SocketIOManager.sharedInstance.serverUrl + "/newProfilePic/"
        let info: [String:Any] = ["username": SocketIOManager.sharedInstance.currUserObj.username as Any, "url": url as Any]

        
        let url = URL(string: geturl);
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<201)
            .responseString{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print(data)
                        print("profile pic added successful")
                    
                case .failure(let error):
                    print("failure trying to save pic to db")
                    print(error)
                    //change profilepic in db to be none now that it is inconsistent with firebase
                    var posturl = SocketIOManager.sharedInstance.serverUrl + "/newProfilePic/"
                    let data: [String:Any] = ["username": SocketIOManager.sharedInstance.currUserObj.username as Any, "url": "none" as Any]
                    let url2 = URL(string: posturl);
                    Alamofire.request(url2!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
                        .validate(statusCode: 200..<201)
                        .responseString{ (response) in
                            print(response)
                            switch response.result {
                            case .success(let data):
                                print(data)
                                print("profile pic added successful")
                                
                            case .failure(let error):
                                print("failure trying to change db to no pic")
                                print(error)
                                
                                let alertController = UIAlertController(title: "Sorry!", message:
                                    "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                    }
                    
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
        }
    }
    
    func getProfilePic(){
        if (!SocketIOManager.sharedInstance.loadedProfilePic){
                   //needs to get image but first should check if the url is in userdefaults
                   print("need to get image")
                   if(UserDefaults.standard.string(forKey: "profilepicurl") != nil){
                    print("url saved in defaults")
                       let picurl = UserDefaults.standard.string(forKey: "profilepicurl")
                       if (picurl != "no profile pic"){
                           //download this pic
                           ImageService.getImage(withURL: picurl!){ image in
                               self.profilePic.image = image
                               
                               self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
                               self.profilePic.clipsToBounds = true
                               print(self.profilePic.frame.height);
                               print(self.profilePic.frame.width);
                               SocketIOManager.sharedInstance.currUserObj.image = image
                               UserDefaults.standard.set(picurl, forKey: "profilepicurl")
                            SocketIOManager.sharedInstance.loadedProfilePic = true
                           }
                       }
                       else {
                           print("no profile pic")
                           let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                           self.profilePic.image = noProfileImage
                           self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
                           self.profilePic.clipsToBounds = true
                           
                           print(self.profilePic.frame.height);
                           print(self.profilePic.frame.width);
                           SocketIOManager.sharedInstance.currUserObj.image = noProfileImage
                           UserDefaults.standard.set("no profile pic", forKey: "profilepicurl")
                        SocketIOManager.sharedInstance.loadedProfilePic = true
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
                                               self.profilePic.image = image
                                               
                                               self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
                                               self.profilePic.clipsToBounds = true
                                               print(self.profilePic.frame.height);
                                               print(self.profilePic.frame.width);
                                               SocketIOManager.sharedInstance.currUserObj.image = image
                                               UserDefaults.standard.set(picurl, forKey: "profilepicurl")
                                            SocketIOManager.sharedInstance.loadedProfilePic = true
                                           }
                                       }
                                       else {
                                           print("no profile pic")
                                           let noProfileImage: UIImage = UIImage(named: "profilepic_none")!
                                           self.profilePic.image = noProfileImage
                                           self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
                                           self.profilePic.clipsToBounds = true
                                           
                                           print(self.profilePic.frame.height);
                                           print(self.profilePic.frame.width);
                                           SocketIOManager.sharedInstance.currUserObj.image = noProfileImage
                                           UserDefaults.standard.set("no profile pic", forKey: "profilepicurl")
                                        SocketIOManager.sharedInstance.loadedProfilePic = true
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
               else {
                   //we already have an image
                   print("image already saved")
                   self.profilePic.image = SocketIOManager.sharedInstance.currUserObj.image
                   self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
                   self.profilePic.clipsToBounds = true
                   print(self.profilePic.frame.height);
                   print(self.profilePic.frame.width);
               }
    }
    
    @objc func uploadProfilePic(image:UIImage){
        print(self.userId)
        let storageRef = Storage.storage().reference().child("profile_pics/" + SocketIOManager.sharedInstance.currUserObj.userId + ".jpg")
        let imageData = image.jpegData(compressionQuality: 0.75)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = storageRef.putData(imageData!, metadata: metaData) { (metadata, error) in
            print(error as Any)
            guard metadata != nil else {
                // Uh-oh, an error occurred!
                return
            }
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                print(error as Any)
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    print("error while getting download url")
                    return
                }
                let stringUrl = downloadURL.absoluteString
                print("printing url returned from firebase")
                print(stringUrl)
                self.downloadUrl = stringUrl
                self.savePicUrltoDB(url: stringUrl)
                UserDefaults.standard.set(stringUrl, forKey: "profilepicurl")
            }
        }
    }
    
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
 

}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.profilePic.image = pickedImage
            SocketIOManager.sharedInstance.currUserObj.image = pickedImage
            self.uploadProfilePic(image: pickedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
