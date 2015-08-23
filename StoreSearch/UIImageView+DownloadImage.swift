//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/22/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        let session = NSURLSession.sharedSession()
        //1. after obtain reference to NSURLSession, creat download task
        let downloadTask = session.downloadTaskWithURL(url, completionHandler: { [weak self] url, response, error in
            //2. make sure error is nil to continue
            if error == nil && url != nil {
                //3. use the local url to load a file into NSData obj and then make an image from that
                if let data = NSData(contentsOfURL: url) {
                    if let image = UIImage(data: data) {
                        //4.once image is created, put it into UIImageView's image property
                        dispatch_async(dispatch_get_main_queue()) {
                            if let strongSelf = self {
                                strongSelf.image = image
                            }
                        }
                    }
                }
            }
        })
        //5. call resume to start and then return the NSURLSessionDownloadTask obj to the caller
        downloadTask.resume()
        return downloadTask
    }
}