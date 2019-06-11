//
//  NewGroupViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 5/23/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class NewGroupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var dataString: String = "";
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var groupDescr: UITextView!
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.delegate = self
        self.groupDescr.delegate = self
        groupDescr.text = "Give your group a description. Tell VShooters why they should join your cool group!"
        //groupDescr.text = "Tell"
        groupDescr.textColor = .lightGray
        name.layer.cornerRadius = CGFloat(Float(4.0))
        createBtn.isEnabled = false
        createBtn.alpha = 0.1
        groupDescr.layer.borderColor = UIColor.black.cgColor
        groupDescr.layer.borderWidth = 1.0
        self.createBtn.layer.cornerRadius = CGFloat(Float(4.0))
        self.cancelBtn.layer.cornerRadius = CGFloat(Float(4.0))
        self.name.layer.cornerRadius = CGFloat(Float(4.0))
        self.groupDescr.layer.cornerRadius = CGFloat(Float(4.0))
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextField.textDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewTapped), name: UITextView.textDidBeginEditingNotification, object: nil)
        
        self.hideKeyboard()
        
    }
    
    @IBAction func showNameSpecs(_ sender: Any) {
        let alertController = UIAlertController(title: "Group Info Details", message:
            "Give your group a cool name of less than 30 characters, for users to find and join your group. Also give it a catchy description in 150 characters or less, telling vshooters why your group is cool! ", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func createGroup(_ sender: Any) {
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/groups"
        let gName = ((self.name.text?.trimmingCharacters(in: .whitespaces))?.lowercased())!
        var descr = "";
        if(self.groupDescr.text != "Give your group a description. Tell VShooters why they should join your cool group!"){
            descr = self.groupDescr.text
        }
        let info: [String:Any] = ["creator": SocketIOManager.sharedInstance.currUserObj.userId as Any, "gname": gName as Any, "descr": descr as Any]
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
                        let newGroup = Group.init(name: gName, creator: SocketIOManager.sharedInstance.currUserObj.username, description: descr)
                        SocketIOManager.sharedInstance.currUserObj.groups.append(newGroup)
                        let alertController = UIAlertController(title: "Great!", message:
                            "Your group has been created! Start inviting vshooters now to build your photo buddy community.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                            //DataReloadManager.shared.firstVC.groupsTableView.reloadData()
                            self.dismiss(animated: true, completion: nil) }))
                        
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
        if (name.hasText && groupDescr.hasText && groupDescr.text != "Give your group a description. Tell VShooters why they should join your cool group!"){
            createBtn.isEnabled = true
            createBtn.alpha = 1.0
        }
        else {
            createBtn.isEnabled = false
            createBtn.alpha = 0.1
        }
    }
    
    @objc func textViewTapped(sender: NSNotification){
        if(self.groupDescr.text == "Give your group a description. Tell VShooters why they should join your cool group!"){
            groupDescr.text = ""
            groupDescr.textColor = .black
        }
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0 {
//                //keyboardSize.height
//                self.view.frame.origin.y -= 50
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
//    }
    
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ "
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        var allowMoreChars:Bool = true
        if ((textField.text?.count)! + (string.count - range.length)) > 30 {
            allowMoreChars = false;
        }
        return ((string == filtered) && allowMoreChars)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 150
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
