//
//  VModelProfileViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 3/1/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class VModelProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var userId:String!
    var currUser:String!
    var downloadUrl:String = ""
    var vshootId: NSInteger = 0
    var vshootRequestor: String = ""
    var myRole: String = ""
    var accessToken:String = ""
    var roomName:String = ""
    var vshoots:[VShoot] = [VShoot]()
    
    var screenSize: CGRect!
    var cvWidth: CGFloat!
    var cvHeight: CGFloat!
    
    
    @IBOutlet weak var VShootsCV: UICollectionView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var numVshootsLabel: UILabel!
    @IBOutlet weak var numFriendsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
        self.profilePic.clipsToBounds = true
        self.numFriendsLabel.isUserInteractionEnabled = true

//        cvWidth = VShootsCV.frame.size.width
//        cvHeight = VShootsCV.frame.size.height
        //let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

        //layout.itemSize = CGSize(width: (cvWidth - 10)/2, height: (cvWidth - 10)/2)
        
        //layout.minimumInteritemSpacing = 0
        //layout.minimumLineSpacing = 0
        //VShootsCV!.collectionViewLayout = layout
        
        self.currUser = SocketIOManager.sharedInstance.currUser
        self.usernameLabel.text = currUser
        print(SocketIOManager.sharedInstance.currUserObj.vshoots)
        getProfilePic()
        if (!SocketIOManager.sharedInstance.loadedFriends){
            getFriends(completion: {
                self.numFriendsLabel.text = String(SocketIOManager.sharedInstance.currUserObj.friends.count)
                //let friendstap = UITapGestureRecognizer(target: self, action: #selector(VModelProfileViewController.FriendsTapFunction))
                //self.numFriendsLabel.addGestureRecognizer(friendstap)
            })
        }
        else {
            self.numFriendsLabel.text = String(SocketIOManager.sharedInstance.currUserObj.friends.count)
            //let friendstap = UITapGestureRecognizer(target: self, action: #selector(VModelProfileViewController.FriendsTapFunction))
            //self.numFriendsLabel.addGestureRecognizer(friendstap)
        }
        
//        getVShoots(completion: {
//            self.numVshootsLabel.text = String(self.vshoots.count)
//            self.VShootsCV.reloadData()
//        })
        
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
                    
                    SocketIOManager.sharedInstance.currUserObj.image = nil
                    UserDefaults.standard.set("", forKey: "username")
                    UserDefaults.standard.set(false, forKey: "UserLoggedIn")
                    
                    UserDefaults.standard.set(nil, forKey: "profilepicurl")
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
    
    
    func getVShoots(completion: @escaping () -> ()){
        //Start off by just getting VShoots id, date, and cover photo
        let testImg = UIImage(named: "profilepic_none")
        let vshoot1 = VShoot.init(coverPhoto: testImg!, date: "10/1/2020")
        let vshoot2 = VShoot.init(coverPhoto: testImg!, date: "10/2/2020")
        let vshoot3 = VShoot.init(coverPhoto: testImg!, date: "10/3/2020")
        let vshoot4 = VShoot.init(coverPhoto: testImg!, date: "10/4/2020")
        let vshoot5 = VShoot.init(coverPhoto: testImg!, date: "10/5/2020")
        let vshoot6 = VShoot.init(coverPhoto: testImg!, date: "10/6/2020")
        
        vshoots.append(vshoot1)
        vshoots.append(vshoot2)
        vshoots.append(vshoot3)
        vshoots.append(vshoot4)
        vshoots.append(vshoot5)
        vshoots.append(vshoot6)
        
        completion()
    }
    
    @objc func FriendsTapFunction() {
        performSegue(withIdentifier: "ToFriendsSegue", sender: self)
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
    
    func getProfilePic(){
        if (SocketIOManager.sharedInstance.currUserObj.image == nil){
                   //needs to get image but first should check if the url is in userdefaults
                   print("need to get image")
                   if(UserDefaults.standard.string(forKey: "profilepicurl") != nil){
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
                       }
                   }
                   else {
                       //first time fetching the photo so need to get it from Server
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
                                           ImageService.getImage(withURL: picurl){ image in
                                               self.profilePic.image = image
                                               
                                               self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
                                               self.profilePic.clipsToBounds = true
                                               print(self.profilePic.frame.height);
                                               print(self.profilePic.frame.width);
                                               SocketIOManager.sharedInstance.currUserObj.image = image
                                               UserDefaults.standard.set(picurl, forKey: "profilepicurl")
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vshoots.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = VShootsCV.dequeueReusableCell(withReuseIdentifier: "VShootCell", for: indexPath) as! VShootCollectionViewCell
        cell.vshootCoverImg.image = vshoots[indexPath.row].coverPhoto
        cell.dateLabel.text = vshoots[indexPath.row].date
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
