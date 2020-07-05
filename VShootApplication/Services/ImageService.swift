//
//  ImageService.swift
//  VShootApplication
//
//  Created by Candice Wright on 1/7/19.
//  Copyright © 2019 Candice Wright. All rights reserved.
//

import Foundation
import UIKit

class ImageService {
    static let cache = NSCache<NSString, UIImage>()
    
    static func downloadImage(myUrl:String, completion: @escaping (_ image:UIImage?)->()){
        //var request = URLRequest(url:myUrl)
        print("trying to download image")
        let url = URL(string: myUrl)
        print(url)
        let dataTask = URLSession.shared.dataTask(with: url!){ data, url, error in
            var downloadedImage:UIImage?
            print(data)
            print(error)
            if let data = data {
                print(myUrl)
                downloadedImage = UIImage(data: data)
                if (downloadedImage != nil){
                    cache.setObject(downloadedImage!, forKey: myUrl as NSString)
                }
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        dataTask.resume()
    }
    
    static func getImage(withURL url:String, completion: @escaping (_ image:UIImage?)->()) {
        if let image = cache.object(forKey: url as NSString) {
            print("cached image")
            completion(image)
        } else {
            downloadImage(myUrl: url, completion: completion)
        }
    }
}
