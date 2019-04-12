//
//  HomeScreenViewController.swift
//  VShootApplication
//
//  Created by Princess Candice on 7/28/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {
    var username = String()
    @IBOutlet weak var welcomeMsg: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeMsg.text = "Welcome "  + username
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //                        print(result)
    //                        //print(result["userExists"] as Any)
    //                        //if (result["userExists"] == "Yes" ){
    //                        if (result.count != 0){
    //                            print("in user exists")
    //                            let securityQuestionNum = result[0]["securityQuestion"]!
    //                            if (securityQuestionNum as! Int == 1){
    //                                self.securityQuestion = "What is your mother's maiden name?"
    //                            }
    //                            else if(securityQuestionNum as! Int == 2){
    //                                self.securityQuestion = "What street did you grow up on?"
    //                            }
    //                            else if(securityQuestionNum as! Int == 3){
    //                                self.securityQuestion = "In what city were you born?"
    //                            }
    //                            else if (securityQuestionNum as! Int == 4){
    //                                self.securityQuestion = "What was the make of your first car?"
    //                            }
    //                            else {
    //                                self.securityQuestion = "What high school did you go to?"
    //                            }
    //                            self.securityAnswerEncrypted = result[0]["securityQAnswer"]! as! String
    //                            print(self.securityQuestion)
    //                            print(self.securityAnswerEncrypted)
    //                            self.performSegue(withIdentifier: "segueToSecurityQuestion", sender: self)
    //                        }
    //
    //                        else {
    //                            //failed
    //                            print("user doesn't exist")
    //                            let alertController = UIAlertController(title: "OOPS", message:
    //                                "No User exists with the given username. Please try again.", preferredStyle: UIAlertController.Style.alert)
    //                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
    //
    //                            self.present(alertController, animated: true, completion: nil)
    //                        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
