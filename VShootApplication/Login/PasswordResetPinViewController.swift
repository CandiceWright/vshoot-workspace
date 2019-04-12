//
//  PasswordResetPinViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 2/16/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class PasswordResetPinViewController: UIViewController {
    var username:String = ""
    @IBOutlet weak var pinTF: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pinTF.layer.cornerRadius = CGFloat(Float(4.0))
        self.nextBtn.layer.cornerRadius = CGFloat(Float(4.0))
        self.cancelBtn.layer.cornerRadius = CGFloat(Float(4.0))
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextField.textDidChangeNotification, object: nil)
        nextBtn.isEnabled = false
        nextBtn.alpha = 0.5
        //dismiss keyboard if touch outside text field
        //setupKeyboardDismissRecognizer()
        self.hideKeyboard()
        
    }
    
    @objc func textChanged(sender: NSNotification) {
        if (pinTF.hasText){
            nextBtn.isEnabled = true
            nextBtn.alpha = 1.0
        }
        else {
            nextBtn.isEnabled = false
            nextBtn.alpha = 0.5
        }
    }
    
    
    
    @IBAction func nextStep(_ sender: Any) {
        self.nextBtn.isEnabled = false
        self.cancelBtn.isEnabled = false
        //check to see if pin is coorrect
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/user/pin/validate"
        //geturl += UsernameField.text! + "/"
        //geturl += PasswordField.text!
        let info: [String:Any] = ["username": username as Any, "pin": pinTF.text as Any]
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
                    if (data == "correct pin"){
                        print("correct pin")
                        self.performSegue(withIdentifier: "segueToNewPassVC", sender: self)
                    }
                    else if (data == "pin expired"){
                        let alertController = UIAlertController(title: "OOPS", message:
                            "Looks like your pin has expired. We'll redirect you to request a new pin.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                            
                            //go back to passwordresetusername vs
                            self.performSegue(withIdentifier: "toPassResetUsernameVCFromPinVC", sender: self)
                            
                            
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        print("wrong pin")
                        
                        let alertController = UIAlertController(title: "OOPS", message:
                            "Looks like you've entered the wrong pin. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                            
                            self.nextBtn.isEnabled = true
                            self.cancelBtn.isEnabled = true
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                    
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToNewPassVC"){
            let passController = segue.destination as! PasswordResetViewController
            passController.username = self.username
            
        }
    }
 

}
