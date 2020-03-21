//
//  VShootOptionViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 2/29/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire
import SocketIO

class VShootOptionViewController: UIViewController {
    
    var friends:Array<String> = []
    
    @IBOutlet weak var VSPhotographerBtn: UIButton!
    
    @IBOutlet weak var VSFriendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.VSPhotographerBtn.layer.cornerRadius = CGFloat(Float(10.0))
        self.VSFriendBtn.layer.cornerRadius = CGFloat(Float(10.0))
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func StartVSwithOnDemandPhotographer(_ sender: Any) {
    }
    
    @IBAction func StartVSWithFriend(_ sender: Any) {
        //if (SocketIOManager.sharedInstance.purchases.keys.contains("com.thevshoot.vshootapp.vshootfuncpurchase") || UserDefaults.standard.object(forKey: "freeTrialAvailable") == nil){ //it is purchased or free trial
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
        //}
//        else {
//            //they have already used their free trial so they need to pay
//            self.performSegue(withIdentifier: "VSPurchaseWindowSegue", sender: self)
//
//        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let destinationVC:NewVSInfoPopupViewController = segue.destination as! NewVSInfoPopupViewController
        
        destinationVC.username = SocketIOManager.sharedInstance.currUser
        destinationVC.friends = self.friends
    }
    

}
