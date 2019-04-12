//
//  UsernameRecoveryViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 2/19/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class UsernameRecoveryViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.email.layer.cornerRadius = CGFloat(Float(4.0))
        self.password.layer.cornerRadius = CGFloat(Float(4.0))
        self.doneBtn.layer.cornerRadius = CGFloat(Float(4.0))
        self.cancelBtn.layer.cornerRadius = CGFloat(Float(4.0))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextField.textDidChangeNotification, object: nil)
        doneBtn.isEnabled = false
        doneBtn.alpha = 0.5
        //dismiss keyboard if touch outside text field
        //setupKeyboardDismissRecognizer()
        self.hideKeyboard()
    }
    
    @objc func textChanged(sender: NSNotification) {
        if (email.hasText && password.hasText){
            doneBtn.isEnabled = true
            doneBtn.alpha = 1.0
        }
        else {
            doneBtn.isEnabled = false
            doneBtn.alpha = 0.5
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
    
    @IBAction func recoverUsername(_ sender: Any) {
        self.doneBtn.isEnabled = false
        self.cancelBtn.isEnabled = false
        //check to see if pin is coorrect
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/user/getusername"
        //geturl += UsernameField.text! + "/"
        //geturl += PasswordField.text!
        //print(email.text)
        let info: [String:Any] = ["email": email.text as Any, "password": password.text as Any]
        //        do {
        //            let data = try JSONSerialization.data(withJSONObject: info, options: [])
        //            dataString = String(data: data, encoding: .utf8)!
        //        } catch {
        //            print("error")
        //        }
        
        let url = URL(string: posturl);
        
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<201)
            .responseString{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print(data)
                    if (data == "email doesn't exist"){
                        self.doneBtn.isEnabled = true
                        self.cancelBtn.isEnabled = true
                        let alertController = UIAlertController(title: "OOPS", message:
                            "Looks like that email doesn't exist. Please try again or email us at info@thevshoot.com for assistance", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                            
                            
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else if (data == "wrong password"){
                        self.doneBtn.isEnabled = true
                        self.cancelBtn.isEnabled = true
                        let alertController = UIAlertController(title: "OOPS", message:
                            "Looks like that password doesn't match your email. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                            
                            
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        print("all good")
                        var username = data
                        let alertController = UIAlertController(title: username, message:
                            "Your username is " + username + ". If you think this is incorrect, please email us at info@thevshoot.com", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                            
                            self.performSegue(withIdentifier: "backToLoginFromUNRecoovery", sender: self)
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                    self.doneBtn.isEnabled = true
                    self.cancelBtn.isEnabled = true
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
        }
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
