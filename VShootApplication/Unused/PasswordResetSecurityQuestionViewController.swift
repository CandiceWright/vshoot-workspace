//
//  PasswordResetSecurityQuestionViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/23/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class PasswordResetSecurityQuestionViewController: UIViewController {
    var username:String = ""
    var securityQuestion:String = ""
    var securityQAEncrypted: String = ""
    var dataString: String = "";
    
    @IBOutlet weak var securityQuestionLabel: UILabel!
    @IBOutlet weak var securityQuestionAnswer: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var errLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.securityQuestionLabel.text = self.securityQuestion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.securityQuestionAnswer.layer.cornerRadius = CGFloat(Float(4.0))
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
        if (securityQuestionAnswer.hasText){
            nextBtn.isEnabled = true
            nextBtn.alpha = 1.0
        }
        else {
            nextBtn.isEnabled = false
            nextBtn.alpha = 0.5
        }
    }
    
    @IBAction func next(_ sender: Any) {
        
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/user/securityQuestion"
        
        
        let info: [String:Any] = ["correctAnswer": securityQAEncrypted as Any, "givenAnswer": securityQuestionAnswer.text as Any]
        do {
            let data = try JSONSerialization.data(withJSONObject: info, options: [])
            dataString = String(data: data, encoding: .utf8)!
        } catch {
            print("error")
        }
        
        let url = URL(string: posturl);
        
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<201)
            .responseString{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print(data)
                    if(data == "Correct Answer"){
                        self.performSegue(withIdentifier: "passwordResetSegue", sender: self)
                    }
                    else {
                        let alertController = UIAlertController(title: "OOPS!", message:
                            "Incorrect Answer. Please try again.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                        
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
        if (segue.identifier == "passwordResetSegue"){
            let passwordResetController = segue.destination as! PasswordResetViewController
            passwordResetController.username = self.username
            
        }
    }
    

}
