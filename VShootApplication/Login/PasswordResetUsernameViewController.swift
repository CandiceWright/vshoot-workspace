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
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var errLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.usernameTF.layer.cornerRadius = CGFloat(Float(8.0))
        self.nextBtn.layer.cornerRadius = CGFloat(Float(9.0))
        self.cancelBtn.layer.cornerRadius = CGFloat(Float(9.0))
        
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
        //send a request to server to see if username exists. If it does, segue to ask security question and pass UN
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/user/security/" + usernameTF.text!
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    if let result = data as? [Dictionary<String,Any>]{
                        print(result)
                        //print(result["userExists"] as Any)
                        //if (result["userExists"] == "Yes" ){
                        if (result.count != 0){
                            print("in user exists")
                            let securityQuestionNum = result[0]["securityQuestion"]!
                            if (securityQuestionNum as! Int == 1){
                                self.securityQuestion = "What is your mother's maiden name?"
                            }
                            else if(securityQuestionNum as! Int == 2){
                                self.securityQuestion = "What street did you grow up on?"
                            }
                            else if(securityQuestionNum as! Int == 3){
                                self.securityQuestion = "In what city were you born?"
                            }
                            else if (securityQuestionNum as! Int == 4){
                                self.securityQuestion = "What was the make of your first car?"
                            }
                            else {
                                self.securityQuestion = "What high school did you go to?"
                            }
                            self.securityAnswerEncrypted = result[0]["securityQAnswer"]! as! String
                            print(self.securityQuestion)
                            print(self.securityAnswerEncrypted)
                            self.performSegue(withIdentifier: "segueToSecurityQuestion", sender: self)
                        }
//                        else if (result["userExists"] == "No"){
//                            self.errLabel.textColor = UIColor.red
//                            self.errLabel.text = "Username doesn't exist."
//                        }
                        else {
                            //failed
                            self.errLabel.textColor = UIColor.red
                            self.errLabel.text = "Username doesn't exist."
                        }
                    }
                    
                    
                    
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                }
        }
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToSecurityQuestion"){
            let securityQuestionController = segue.destination as! PasswordResetSecurityQuestionViewController
            securityQuestionController.username = self.usernameTF.text!
            securityQuestionController.securityQuestion = self.securityQuestion
            securityQuestionController.securityQAEncrypted = self.securityAnswerEncrypted
        }
        
    }
 

}
