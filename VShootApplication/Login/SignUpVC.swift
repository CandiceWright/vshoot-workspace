//
//  SignUpVC.swift
//  VShootApplication
//
//  Created by Princess Candice on 7/29/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireSwiftyJSON
import SwiftyJSON
import FirebaseAuth
import iOSDropDown

class SignUpVC: UIViewController {
    
    var question:Int = 0
    var usernameStr:String = ""
    @IBOutlet weak var email: UITextField!
    //@IBOutlet weak var phone: UITextField!
   
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    var dataString: String = "";
    @IBOutlet weak var err: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var SecurityQuestion: DropDown!
    @IBOutlet weak var SQAnswer: UITextField!
    
    
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var signupErr: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.phone.layer.cornerRadius = CGFloat(Float(2.0))
        self.email.layer.cornerRadius = CGFloat(Float(2.0))
        self.username.layer.cornerRadius = CGFloat(Float(2.0))
        self.password.layer.cornerRadius = CGFloat(Float(2.0))
        //self.SecurityQuestion.layer.cornerRadius = CGFloat(Float(2.0))
        //self.SQAnswer.layer.cornerRadius = CGFloat(Float(2.0))
        self.signUpButton.layer.cornerRadius = CGFloat(Float(4.0))
        self.cancelButton.layer.cornerRadius = CGFloat(Float(4.0))
        signUpButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        
        // The list of array to display. Can be changed dynamically
        //SecurityQuestion.optionArray = ["What is your mother's maiden name?", "What street did you grow up on?", "In what city were you born?", "What was the make of your first car?", "What high school did you go to?"]
        //Its Id Values and its optional
        //SecurityQuestion.optionIds = [1,2,3,4,5]
        // The the Closure returns Selected Index and String
        //SecurityQuestion.didSelect{(selectedText , index ,id) in
            //self.question = id
            //print(self.question)
            
        //}
        //SecurityQuestion.listWillAppear {
            //print("hiding")
            //self.SQAnswer.isHidden = true
            //self.dismissKeyboard()
        //}
//        SecurityQuestion.listDidDisappear {
//            print("unhiding")
//            self.SQAnswer.isHidden = false
//        }
        //SecurityQuestion.listWillDisappear {
            //print("unhiding")
            //self.SQAnswer.isHidden = false
        //}
        //SecurityQuestion.isSearchEnable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextField.textDidChangeNotification, object: nil)
        signUpButton.isEnabled = false
        signUpButton.alpha = 0.5
        //dismiss keyboard if touch outside text field
        //setupKeyboardDismissRecognizer()
        self.hideKeyboard()
        
    }
    
    @objc func textChanged(sender: NSNotification) {
        if (username.hasText && password.hasText && email.hasText){
            signUpButton.isEnabled = true
            signUpButton.alpha = 1.0
        }
        else {
            signUpButton.isEnabled = false
            signUpButton.alpha = 0.5
        }
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
//
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
    
    @IBAction func signUp(_ sender: Any) {
        self.cancelButton.isEnabled = false
        self.signUpButton.isEnabled = false
            //save all info then segue to home
//        var result = ""
//        repeat {
//            // Create a string with a random number 0...9999
//            result = String(format:"%04d", arc4random_uniform(10000) )
//        } while result.count < 4
        
            var geturl = SocketIOManager.sharedInstance.serverUrl + "/signup"
        self.usernameStr = ((self.username.text?.trimmingCharacters(in: .whitespaces))?.lowercased())!
        let info: [String:Any] = ["username": self.usernameStr as Any, "password": password.text as Any, "email": email.text as Any]
        //"securityQuestion": self.question as Any, "securityAnswer": SQAnswer.text as Any
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
                        if (data == "username taken"){
                            self.cancelButton.isEnabled = true
                            self.signUpButton.isEnabled = true
                            let alertController = UIAlertController(title: "OOPS", message:
                                "This username is taken. Please choose another.", preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                        else {
                            //notify the server to store relationship between this user and its socket
                            SocketIOManager.sharedInstance.storeSocketRef(username: self.usernameStr, completion: {
                                let token = data
                                Auth.auth().signIn(withCustomToken: token, completion: {user, error in
                                    if let error = error {
                                        print("unable to sign in with error \(error)")
                                    }
                                })
                                self.performSegue(withIdentifier: "segueToOnboard", sender: self)
                                
                            });
                        }
                        
                    case .failure(let error):
                        print("failure")
                        print(error)
                        self.cancelButton.isEnabled = true
                        self.signUpButton.isEnabled = true
                        let alertController = UIAlertController(title: "Sorry!", message:
                            "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
            }
        
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToHomeFromSignUp"){
            let barViewControllers = segue.destination as! UITabBarController
            barViewControllers.selectedIndex = 1
            
            let VSViewController = barViewControllers.viewControllers?[1] as! InitiateVSViewController
            VSViewController.username = self.usernameStr
        }
        
    }

}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
