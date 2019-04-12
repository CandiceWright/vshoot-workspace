//
//  ProfileEmailChangeViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/9/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class ProfileEmailChangeViewController: UIViewController {

    @IBOutlet weak var newEmail: UITextField!
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
    
    @IBAction func changeEmail(_ sender: Any) {
        if (newEmail.text == ""){
            //errorLabel.text = "New Username Cannot be Blank"
            let alertController = UIAlertController(title: "Sorry!", message:
                "New Email cannot be blank.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            self.cancelBtn.isEnabled = false
            self.savBtn.isEnabled = false
            var geturl = SocketIOManager.sharedInstance.serverUrl + "/user/email"
            
            let info: [String:Any] = ["currUser": currUser as Any, "newEmail": newEmail.text as Any]
            
            let url = URL(string: geturl);
            
            Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
                .validate(statusCode: 200..<201)
                .responseString{ (response) in
                    print(response)
                    switch response.result {
                    case .success(let data):
                        print(data)
                        self.dismiss(animated: true, completion: nil)
                        
                        
                    case .failure(let error):
                        print("failure")
                        print(error)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
