//
//  WalkthroughViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 2/15/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController, WalkThroughPageViewControllerDelegate {
    
    var walkThroughPageViewController: WalkthroughPageViewController?
    
    @IBOutlet weak var pageControllerr: UIPageControl!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func skip(_ sender: Any) {
        self.performSegue(withIdentifier: "doneOnBoardingSegue", sender: self)
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        pageControllerr.currentPage = currentIndex
        if currentIndex == 2 {
            self.skipBtn.setTitle("Get Started", for: UIControl.State.normal)
            let greenColor = UIColor(rgb: 0x31D283)
            self.skipBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
            self.skipBtn.backgroundColor = greenColor
            //self.skipBtn.frame.size = CGSize(width: 65, height: 33)
            
            
            self.skipBtn.layer.cornerRadius = CGFloat(3.0)
        }
        else {
            self.skipBtn.setTitle("Skip", for: UIControl.State.normal)
            self.skipBtn.backgroundColor = UIColor.white
            self.skipBtn.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "doneOnBoardingSegue"){
            let barViewControllers = segue.destination as! UITabBarController
            barViewControllers.selectedIndex = 1
            print(barViewControllers.viewControllers?.count)
            let VSViewController = barViewControllers.viewControllers?[0] as! InitiateVSViewController
            VSViewController.username = SocketIOManager.sharedInstance.currUserObj.username
           
            
        }
        else {
            let destination = segue.destination
            if let pageVC = destination as? WalkthroughPageViewController {
                walkThroughPageViewController = pageVC
                walkThroughPageViewController?.walkthroughDelegate = self
            }
        }
    }
 

}
