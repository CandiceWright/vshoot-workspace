//
//  NewGroupViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/23/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class NewGroupViewController: UIViewController {

    var dataString: String = "";
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var groupDescr: UITextView!
    @IBOutlet weak var createBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupDescr.text = "Tell VShooters why they should join this group. Optional, but recommended!"
        groupDescr.textColor = .gray
        name.layer.cornerRadius = CGFloat(Float(4.0))
        createBtn.isEnabled = false
        createBtn.alpha = 0.1
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextField.textDidChangeNotification, object: nil)
        
        self.hideKeyboard()
        
    }
    
    @IBAction func createGroup(_ sender: Any) {
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/groups"
        let gName = ((self.name.text?.trimmingCharacters(in: .whitespaces))?.lowercased())!
        var descr = "";
        if(self.groupDescr.text != "Tell VShooters why they should join this group. Optional, but recommended!"){
            descr = self.groupDescr.text
        }
        let info: [String:Any] = ["creator": SocketIOManager.sharedInstance.currUserObj.username as Any, "gname": gName as Any, "descr": descr as Any]
        //"securityQuestion": self.question as Any, "securityAnswer": SQAnswer.text as Any
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
                    if (data == "created group successfully"){
                        let alertController = UIAlertController(title: "Great!", message:
                            "Your group has been created! Start inviting vshooters now to build your photo buddy community.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in self.dismiss(animated: true, completion: nil) }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        let alertController = UIAlertController(title: "Oops!", message:
                            "There's already a group with that name.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in  }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    
                    
                case .failure(let error):
                    print("failure")
                    print(error)
                   
                    self.createBtn.isEnabled = false
                    let alertController = UIAlertController(title: "Sorry!", message:
                        "Looks like something went wrong. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func textChanged(sender: NSNotification) {
        if (name.hasText){
            createBtn.isEnabled = true
            createBtn.alpha = 1.0
        }
        else {
            createBtn.isEnabled = false
            createBtn.alpha = 0.1
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
