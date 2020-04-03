//
//  PasswordResetUsernameViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/23/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class PasswordResetUsernameViewController: UIViewController {

    var securityQuestion: String = ""
    var securityAnswerEncrypted: String = ""
    var dataString: String = "";
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var errLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.usernameTF.layer.cornerRadius = CGFloat(Float(4.0))
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
        if (usernameTF.hasText){
            nextBtn.isEnabled = true
            nextBtn.alpha = 1.0
        }
        else {
            nextBtn.isEnabled = false
            nextBtn.alpha = 0.5
        }
    }
    
    @IBAction func next(_ sender: Any) {
        nextBtn.isEnabled = false
        cancelBtn.isEnabled = false
        //send a request to server to see if username exists. If it does, segue to ask security question and pass UN
        //let username = (usernameTF.text?.trimmingCharacters(in: .whitespaces))?.lowercased()
        print("this is the username " + self.usernameTF.text! as Any)
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/forgotPass"
        
        let info: [String:Any] = ["username": self.usernameTF.text! as Any]
        //"securityQuestion": self.question as Any, "securityAnswer": SQAnswer.text as Any
        do {
            let data = try JSONSerialization.data(withJSONObject: info, options: [])
            dataString = String(data: data, encoding: .utf8)!
        } catch {
            print("error")
        }
        
        let url = URL(string: geturl)
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<201)
            .responseString{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                        //self.performSegue(withIdentifier: "pinVCSegue", sender: self)
                    if (data == "no user exists"){
                        self.nextBtn.isEnabled = true
                        self.cancelBtn.isEnabled = true
                        let alertController = UIAlertController(title: "OOPS", message: "There is no user with that username. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else if (data == "could not send email"){ //bad email
                        self.nextBtn.isEnabled = true
                        self.cancelBtn.isEnabled = true
                        let alertController = UIAlertController(title: "OOPS", message: "We couldn't send you a password reset link because the email you signed up with is not a valid email. Please email us at info@thevshoot.com for further assistance.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else { //successful
                        let alertController = UIAlertController(title: "Password Reset", message: "We've sent you an email with a reset code which you'll enter on the next screen", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                            
                            self.performSegue(withIdentifier: "pinVCSegue", sender: self)
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }

                    
                    
                    
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                    self.nextBtn.isEnabled = true
                    self.cancelBtn.isEnabled = true
                    let alertController = UIAlertController(title: "OOPS", message: "Looks like there was a problem. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
        }
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "segueToSecurityQuestion"){
//            let securityQuestionController = segue.destination as! PasswordResetSecurityQuestionViewController
//            securityQuestionController.username = self.usernameTF.text!
//            securityQuestionController.securityQuestion = self.securityQuestion
//            securityQuestionController.securityQAEncrypted = self.securityAnswerEncrypted
//        }
        
        if (segue.identifier == "pinVCSegue"){
            let pinController = segue.destination as! PasswordResetPinViewController
            pinController.username = usernameTF.text!
           
        }
        
    }
 

}
