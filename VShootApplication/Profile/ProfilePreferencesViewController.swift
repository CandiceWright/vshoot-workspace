//
//  ProfilePreferencesViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/26/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import iOSDropDown
import Alamofire

class ProfilePreferencesViewController: UIViewController {
    
    var preference:String = SocketIOManager.sharedInstance.currUserObj.vsPreference
    var currUser = SocketIOManager.sharedInstance.currUserObj.username
    @IBOutlet weak var preferenceOptionsDropDown: DropDown!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveBtn.layer.cornerRadius = CGFloat(Float(4.0))
        self.cancelBtn.layer.cornerRadius = CGFloat(Float(4.0))
        saveBtn.titleLabel?.adjustsFontSizeToFitWidth = true;
        cancelBtn.titleLabel?.adjustsFontSizeToFitWidth = true;
        preferenceOptionsDropDown.optionArray = ["Only my Votographriends", "Anyone"]
        //Its Id Values and its optional
        preferenceOptionsDropDown.optionIds = [1,2]
        // The the Closure returns Selected Index and String
        preferenceOptionsDropDown.didSelect{(selectedText , index ,id) in
            self.preference = String(id)
            print(self.preference)
            
            
        }
        preferenceOptionsDropDown.isSearchEnable = false
        
        preferenceOptionsDropDown.listWillAppear {
            print("hiding")
            self.saveBtn.isHidden = true
            self.cancelBtn.isHidden = true
            //self.dismissKeyboard()
        }

        preferenceOptionsDropDown.listWillDisappear {
            print("unhiding")
            self.saveBtn.isHidden = false
            self.cancelBtn.isHidden = false
        }
        print(SocketIOManager.sharedInstance.currUserObj.vsPreference)
        if (SocketIOManager.sharedInstance.currUserObj.vsPreference == "1"){
            preferenceOptionsDropDown.text = "Only my Votographriends"
        }
        else {
            preferenceOptionsDropDown.text = "Anyone"
        }
        
        
    }
    
    
    @IBAction func savePreferences(_ sender: Any) {
        if (SocketIOManager.sharedInstance.currUserObj.vsPreference == self.preference){
            dismiss(animated: true, completion: nil)
        }
        else {
            self.cancelBtn.isEnabled = false
            self.saveBtn.isEnabled = false
            var posturl = SocketIOManager.sharedInstance.serverUrl + "/user/preference"
            
            let info: [String:Any] = ["currUser": currUser as Any, "newPref": preference as Any]
            
            let url = URL(string: posturl);
            
            Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
                .validate(statusCode: 200..<201)
                .responseString{ (response) in
                    print(response)
                    switch response.result {
                    case .success(let data):
                        print(data)
                            SocketIOManager.sharedInstance.currUserObj.vsPreference = self.preference
                            print(SocketIOManager.sharedInstance.currUserObj.vsPreference)
                            self.dismiss(animated: true, completion: nil)
                        
                    case .failure(let error):
                        print("failure")
                        print(error)
                        self.cancelBtn.isEnabled = true
                        self.saveBtn.isEnabled = true
                        let alertController = UIAlertController(title: "Sorry!", message:
                            "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
