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
    var currUser:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

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
            errorLabel.text = "New Username Cannot be Blank"
        }
        else {
            var geturl = SocketIOManager.sharedInstance.serverUrl + "/user/username"
            
            let info: [String:Any] = ["currUsername": currUser as Any, "newUsername": newUsername.text as Any]
            
            let url = URL(string: geturl);
            
            Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
                .validate(statusCode: 200..<500)
                .responseString{ (response) in
                    print(response)
                    switch response.result {
                    case .success(let data):
                        print(data)
                        if (data == "username updated successfully"){
                            SocketIOManager.sharedInstance.currUserObj.username = self.newUsername.text!
                            SocketIOManager.sharedInstance.currUser = self.newUsername.text!
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                        else {
                            print("error trying to change username")
                            //add a label "Sorry request could not be processed. Try again"
                            self.errorLabel.text = "Username is Taken."
                        }
                        
                    case .failure(let error):
                        print("failure")
                        print(error)
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
