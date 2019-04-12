//
//  PasswordResetPhoneViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 2/15/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit
import Alamofire
import MessageUI

class PasswordResetPhoneViewController: UIViewController {
    var username: String = ""
    
    @IBOutlet weak var phoneTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func nextStep(_ sender: Any) {
        let geturl = SocketIOManager.sharedInstance.serverUrl + "/user/pin/validate" + self.username
        print(geturl)
        let url = URL(string: geturl)
        Alamofire.request(url!)
            .validate(statusCode: 200..<201)
            .responseString{ (response) in
                switch response.result {
                case .success(let data):
                    print(data)
                    let correctPhone = data
                    if (correctPhone == self.phoneTF.text){
                        print("correct phone number")
                        //username must exist, so send message
                        let alertController = UIAlertController(title: "Reset Code", message: "We will send you a 4-digit code via text message. Enter it on the next screen.", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                            //send text message then segue
                            var result = ""
                            repeat {
                                // Create a string with a random number 0...9999
                                result = String(format:"%04d", arc4random_uniform(10000) )
                            } while result.count < 4
                            
                            if MFMessageComposeViewController.canSendText() {
                                let controller = MFMessageComposeViewController()
                                controller.body = "Here is your VShoot Code: " + result
                                controller.recipients = [correctPhone]
                                controller.messageComposeDelegate = self
                                self.present(controller, animated: true, completion: nil)
                            }
                            else {
                                print("cannot send message")
                            }
                            
                            
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        let alertController = UIAlertController(title: "OOPS", message: "The number you entered does not match our records. Please try again.", preferredStyle: UIAlertController.Style.alert)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PasswordResetPhoneViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //segue here
    }
    
    
}
