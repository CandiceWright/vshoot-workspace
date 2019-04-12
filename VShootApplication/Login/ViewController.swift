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
import FirebaseAuth

@IBDesignable
class ViewController: UIViewController {
    var dataString: String = "";
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var loginError: UILabel!
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.UsernameField.layer.cornerRadius = CGFloat(Float(10.0))
        self.PasswordField.layer.cornerRadius = CGFloat(Float(10.0))
        self.LoginButton.layer.cornerRadius = CGFloat(Float(9.0))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextField.textDidChangeNotification, object: nil)
        LoginButton.isEnabled = false
        LoginButton.alpha = 0.5
        //dismiss keyboard if touch outside text field
        //setupKeyboardDismissRecognizer()
        self.hideKeyboard()
        
    }
    
    @objc func textChanged(sender: NSNotification) {
        if (UsernameField.hasText && PasswordField.hasText){
            LoginButton.isEnabled = true
            LoginButton.alpha = 1.0
        }
        else {
            LoginButton.isEnabled = false
            LoginButton.alpha = 0.5
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
        if (UsernameField.text == "" || PasswordField.text == ""){
            self.loginError.text = "All field are required";
        }
        else {
            //http://localhost:7343
            var geturl = SocketIOManager.sharedInstance.serverUrl + "/login/"
            //geturl += UsernameField.text! + "/"
            //geturl += PasswordField.text!
            
            let info: [String:Any] = ["username": UsernameField.text as Any, "password": PasswordField.text as Any]
            do {
                let data = try JSONSerialization.data(withJSONObject: info, options: [])
                dataString = String(data: data, encoding: .utf8)!
            } catch {
                print("error")
            }
            
            let url = URL(string: geturl);
            //let url = URL(string: geturl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            //        print(url)
            Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
                .validate(statusCode: 200..<300)
                .responseString{ (response) in
                    print(response)
                    switch response.result {
                    case .success(let data):
                        //                        print("success")
                        //                        print(response.result.value)
                        print(data)
//
                        if (data == "failed"){
                            print("wrong pass")
                            self.loginError.text = "Invalid Password."
                        }
                        else if(data == "no user exists"){
                            print("no user");
                            self.loginError.text = "No user exists with given username."
                        }
                        else {
                            print("login should be successful")
                            print(data)
                            // login is successful so notify the server to store relationship between this user and its socket
                            
                            SocketIOManager.sharedInstance.storeSocketRef(username: self.UsernameField.text!);
                            let token = data
                            Auth.auth().signIn(withCustomToken: token, completion: {user, error in
                                if let error = error {
                                    print("unable to sign in with error \(error)")
                                }
                            })
                            self.performSegue(withIdentifier: "segueToHomeFromLogin", sender: self)
                        }
                        
                    case .failure(let error):
                        print("failure")
                        print(error)
                    }
            }
        }
        
        
    }
    @IBAction func forgotPassword(_ sender: Any) {
    }
    @IBOutlet weak var signUp: UIButton!
    @IBAction func signUpFunc(_ sender: Any) {
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

