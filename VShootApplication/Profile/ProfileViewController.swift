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
//        self.currUser = SocketIOManager.sharedInstance.currUser
        print("I am in view did load")
        //make profile pic round
        //profilePic.layer.borderColor = UIColor.black.cgColor
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
        self.profilePic.clipsToBounds = true
        
        //allow image to be clickable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePic))
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(tapGesture)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshlbl(notification:)), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
        //print("I am in view will appeear")
        print(self.profilePic.frame.height);
        print(self.profilePic.frame.width);
        
        //profilePic.image = nil
        self.currUser = SocketIOManager.sharedInstance.currUser
        self.username.text = currUser
        
        if (SocketIOManager.sharedInstance.currUserObj.image == nil){
            //get userId for profile picture
            print("need to get image")
            let geturl = SocketIOManager.sharedInstance.serverUrl + "/user/" + currUser
            let url = URL(string: geturl)
            Alamofire.request(url!)
                .validate(statusCode: 200..<201)
                .responseString{ (response) in
                    switch response.result {
                    case .success(let data):
                        print(data)
                        if let userId = data as? String {
                            self.userId = userId
                            print("successfully got userid")
                            print(self.userId)
                            //get profile pic url
                            let geturl2 = SocketIOManager.sharedInstance.serverUrl + "/user/profilePic/" + self.currUser
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
                                                ImageService.downloadImage(myUrl: picurl){ image in
                                                    self.profilePic.image = image
                                                 
                                                    self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
                                                    self.profilePic.clipsToBounds = true
                                                    print(self.profilePic.frame.height);
                                                    print(self.profilePic.frame.width);
                                                    SocketIOManager.sharedInstance.currUserObj.image = image
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
                        else {
                            print("cant convert")
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
            //we already have an image
            print("image already saved")
            self.profilePic.image = SocketIOManager.sharedInstance.currUserObj.image
            self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
            self.profilePic.clipsToBounds = true
            print(self.profilePic.frame.height);
            print(self.profilePic.frame.width);
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    @IBAction func changeUsername(_ sender: Any) {
        
    }
    
    @IBAction func changeemail(_ sender: Any) {
    }
    
    @objc func changeProfilePic(){
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        print("logging out")
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/logout"
        let info: [String:Any] = ["username": currUser as Any]
        
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
                    UserDefaults.standard.set("", forKey: "username")
                    UserDefaults.standard.set(false, forKey: "UserLoggedIn")
                        //SocketIOManager.sharedInstance.closeConnection()
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
    
    @objc func refreshlbl(notification: NSNotification) {
        
        username.text = SocketIOManager.sharedInstance.currUser  //Update your label here.
    }

    
    
    @objc func savePicUrltoDB(url:String){
        var geturl = SocketIOManager.sharedInstance.serverUrl + "/newProfilePic/"
        let info: [String:Any] = ["username": currUser as Any, "url": url as Any]
//        do {
//            let data = try JSONSerialization.data(withJSONObject: info, options: [])
//            //dataString = String(data: data, encoding: .utf8)!
//        } catch {
//            print("error")
//        }
        
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
                    print("failure")
                    print(error)
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
        }
    }
    
    @objc func uploadProfilePic(image:UIImage){
        print(self.userId)
        let storageRef = Storage.storage().reference().child("profile_pics/" + self.userId! + ".jpg")
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
