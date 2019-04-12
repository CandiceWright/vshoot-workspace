//
//  ProfileUsernameChangeViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/9/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class ProfileUsernameChangeViewController: UIViewController {

    @IBOutlet weak var newUsername: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var savBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    var currUser:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.savBtn.layer.cornerRadius = CGFloat(Float(4.0))
        self.cancelBtn.layer.cornerRadius = CGFloat(Float(4.0))
        savBtn.titleLabel?.adjustsFontSizeToFitWidth = true;
        cancelBtn.titleLabel?.adjustsFontSizeToFitWidth = true;
        currUser = SocketIOManager.sharedInstance.currUserObj.username
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //dismiss keyboard if touch outside text field
        setupKeyboardDismissRecognizer()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func setupKeyboardDismissRecognizer(){
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc override func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @IBAction func saveNewUsername(_ sender: Any) {
        if (newUsername.text == ""){
            //errorLabel.text = "New Username Cannot be Blank"
            let alertController = UIAlertController(title: "Sorry!", message:
                "New Username cannot be blank.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            self.cancelBtn.isEnabled = false
            self.savBtn.isEnabled = false
            var geturl = SocketIOManager.sharedInstance.serverUrl + "/user/username"
            let username = (newUsername.text?.trimmingCharacters(in: .whitespaces))?.lowercased()
            print(currUser)
            print(username)
            print(username!)
            let info: [String:Any] = ["currUsername": currUser as Any, "newUsername": username as Any]
            
            let url = URL(string: geturl);
            
            Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
                .validate(statusCode: 200..<201)
                .responseString{ (response) in
                    print(response)
                    switch response.result {
                    case .success(let data):
                        print(data)
                        if (data == "username updated successfully"){
                            SocketIOManager.sharedInstance.currUserObj.username = username!
                            SocketIOManager.sharedInstance.currUser = username!
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                        else {
                            print("username taken")
                            self.cancelBtn.isEnabled = true
                            self.savBtn.isEnabled = true
                            //self.errorLabel.text = "Username is Taken."
                            let alertController = UIAlertController(title: "OOPS!", message:
                                "This username is already taken. Try another.", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                    case .failure(let error):
                        print("failure")
                        print(error)
                        print(response)
                        self.cancelBtn.isEnabled = true
                        self.savBtn.isEnabled = true
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
