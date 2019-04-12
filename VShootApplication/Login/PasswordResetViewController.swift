//
//  PasswordResetViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/24/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire

class PasswordResetViewController: UIViewController {
    var dataString:String = ""
    var username:String = ""
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.newPasswordTF.layer.cornerRadius = CGFloat(Float(8.0))
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
        if (newPasswordTF.hasText){
            nextBtn.isEnabled = true
            nextBtn.alpha = 1.0
        }
        else {
            nextBtn.isEnabled = false
            nextBtn.alpha = 0.5
        }
    }
    
    @IBAction func next(_ sender: Any) {
        var posturl = SocketIOManager.sharedInstance.serverUrl + "/user/password"
        
        
        let info: [String:Any] = ["username": self.username as Any, "newPass": self.newPasswordTF.text as Any]
        do {
            let data = try JSONSerialization.data(withJSONObject: info, options: [])
            dataString = String(data: data, encoding: .utf8)!
        } catch {
            print("error")
        }
        
        let url = URL(string: posturl);
        
        Alamofire.request(url!, method: .post, parameters: info, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json"])
            .validate(statusCode: 200..<300)
            .responseString{ (response) in
                print(response)
                switch response.result {
                case .success(let data):
                    print(data)
                    if(data == "password updated successfully"){
                        self.performSegue(withIdentifier: "backToLogin", sender: self)
                    }
                    else {
                        //maybe add a label to say password couldn't be changed
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
