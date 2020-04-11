//
//  WalkthroughPageViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 2/15/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import UIKit

protocol WalkThroughPageViewControllerDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var walkthroughDelegate: WalkThroughPageViewControllerDelegate?
    
//    var pageImages = ["OnboardingPg1","OnboardingPg2","OnboardingPg3"]
    var pageImages = ["VSOnboarding-blurb","VSOnboarding-HowitWorks"]
    var currIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        if let startingVC = contentViewController(at: 0){
            setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
        }
        
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        return contentViewController(at: index)
    }
    
    func contentViewController (at index:Int) -> (WalkthroughContentViewController?){
        if (index < 0 || index >= pageImages.count){
            return nil
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "walkthroughContentVC") as? WalkthroughContentViewController{
                pageContentViewController.imageFile = pageImages[index]
                    pageContentViewController.index = index
                return pageContentViewController
            }
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? WalkthroughContentViewController {
                currIndex = contentViewController.index
                print(currIndex)
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: currIndex)
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
