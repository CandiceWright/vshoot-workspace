//
//  ViewController.swift
//  VShootApplication
//
//  Created by Princess Candice on 7/28/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireSwiftyJSON
import SwiftyJSON
import SocketIO
import SwiftSpinner
import FirebaseAuth

@IBDesignable
class ViewController: UIViewController {
    var dataString: String = "";
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var loginError: UILabel!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("printing logged in status")
        UserDefaults.standard.set(false, forKey: "UserLoggedIn")
       
            self.LoginButton.layer.cornerRadius = CGFloat(Float(4.0))
            self.signUpButton.layer.cornerRadius = CGFloat(Float(4.0))
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextField.textDidChangeNotification, object: nil)
            LoginButton.isEnabled = false
            LoginButton.alpha = 0.1
            //dismiss keyboard if touch outside text field
            //setupKeyboardDismissRecognizer()
            self.hideKeyboard()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(UserDefaults.standard.bool(forKey: "UserLoggedIn"))

        if(UserDefaults.standard.bool(forKey: "UserLoggedIn") == true){
            print("already logged in")
            let username = UserDefaults.standard.string(forKey: "username")
            print("printing username is defaults")
            print(username)
            SocketIOManager.sharedInstance.currUserObj.username = username!
            SocketIOManager.sharedInstance.currUser = username!
            self.performSegue(withIdentifier: "segueToHomeFromLogin", sender: self)
            
//            SocketIOManager.sharedInstance.establishConnection(username: username!, fromLogin: true, completion: {
//                //SwiftSpinner.hide()
//                self.performSegue(withIdentifier: "segueToHomeFromLogin", sender: self)
//
//            })
            
        }
    }
    
    
    @objc func textChanged(sender: NSNotification) {
        if (UsernameField.hasText && PasswordField.hasText){
            LoginButton.isEnabled = true
            LoginButton.alpha = 1.0
        }
        else {
            LoginButton.isEnabled = false
            LoginButton.alpha = 0.1
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                //keyboardSize.height
                self.view.frame.origin.y -= 50
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    @IBAction func Login(_ sender: Any) {
        print("login button pressed")
        self.LoginButton.isEnabled = false
        self.signUpButton.isEnabled = false
            var geturl = SocketIOManager.sharedInstance.serverUrl + "/login/"
            //geturl += UsernameField.text! + "/"
            //geturl += PasswordField.text!
            let username = (UsernameField.text?.trimmingCharacters(in: .whitespaces))?.lowercased()
        print("printing username")
        print(username)
            let info: [String:Any] = ["username": username as Any, "password": PasswordField.text as Any]
            do {
                let data = try JSONSerialization.data(withJSONObject: info, options: [])
                dataString = String(data: data, encoding: .utf8)!
            } catch {
                print("error")
            }
            
            let url = URL(string: geturl);
        
            Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
                .validate(statusCode: 200..<201)
                .responseString{ (response) in
                    print(response)
                    switch response.result {
                    case .success(let data):
                        print(data)
                        if (data == "wrong password"){
                            print("wrong pass")
                            self.LoginButton.isEnabled = true
                            self.signUpButton.isEnabled = true
                            let alertController = UIAlertController(title: "OOPS", message:
                                "Looks like you've entered the wrong password. Please try again.", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else if(data == "no user exists"){
                            print("no user");
                            self.LoginButton.isEnabled = true
                            self.signUpButton.isEnabled = true
                            let alertController = UIAlertController(title: "OOPS", message:
                                "No User exists with the given username. Please try again.", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                            //SwiftSpinner.hide()
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else if(data == "already logged in"){
                            let alertController = UIAlertController(title: "OOPS", message:
                                "Looks like you are already logged in on another device and you can only be logged into one device at a time.", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                        else {
                            print("login should be successful")
                            print(data)
                            SocketIOManager.sharedInstance.currUserObj.username = username!
                            SocketIOManager.sharedInstance.currUser = username!
                            UserDefaults.standard.set(username!, forKey: "username")
                            UserDefaults.standard.set(true, forKey: "UserLoggedIn")
                            let token = data
                            Auth.auth().signIn(withCustomToken: token, completion: {user, error in
                                if let error = error {
                                    print("unable to sign in with error \(error)")
                                }
                            })
                            self.performSegue(withIdentifier: "segueToHomeFromLogin", sender: self)
                            
                            //establish connection, store socket and load friends
//                            SocketIOManager.sharedInstance.establishConnection(username: username!, fromLogin: true, completion: {
//                                print("friends loading complete")
//                                let token = data
//                                Auth.auth().signIn(withCustomToken: token, completion: {user, error in
//                                    if let error = error {
//                                        print("unable to sign in with error \(error)")
//                                    }
//                                })
//                                UserDefaults.standard.set(username!, forKey: "username")
//                                UserDefaults.standard.set(true, forKey: "UserLoggedIn")
//                                self.performSegue(withIdentifier: "segueToHomeFromLogin", sender: self)
//                            })
                            
                        }
                        
                    case .failure(let error):
                        print("failure")
                        print(error)
                        self.LoginButton.isEnabled = true
                        self.signUpButton.isEnabled = true
                        SwiftSpinner.hide()
                        let alertController = UIAlertController(title: "Sorry!", message:
                            "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
            }
        
        
        
    }
    @IBAction func forgotPassword(_ sender: Any) {
    }
    
    @IBAction func createAccount(_ sender: Any) {
        self.performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToHomeFromLogin"){
            let barViewControllers = segue.destination as! UITabBarController
            barViewControllers.selectedIndex = 1
            
             let VSViewController = barViewControllers.viewControllers?[1] as! InitiateVSViewController
            VSViewController.username = UsernameField.text!
//            let FriendsViewController = barViewControllers.viewControllers?[0] as! FriendsViewController
//            FriendsViewController.username = UsernameField.text!
//            let ProfileViewController = barViewControllers.viewControllers?[2] as! ProfileViewController
//            ProfileViewController.username = UsernameField.text!

        }
        
    }


}

