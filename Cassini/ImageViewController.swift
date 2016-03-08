//
//  ImageViewController.swift
//  Cassini
//
//  Created by Angelo Wong on 3/7/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageURL: NSURL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage() //don't fetch expensive data if they are not looking at the app.
            }
            
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    private func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating() //in case we fetch image prematurely
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0), { () -> Void in
                print ("fetching img")
                let imageData = NSData(contentsOfURL: url) //this line could be very slow, so put it in an async thread
                
                //this is UI stuff and so put it back in main queue
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if imageData != nil {
                            self.image = UIImage(data: imageData!)
                        } else {
                            self.image = nil
                        }
                    }
                }
                
            })

        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size //optional chaining just to be safe
            spinner?.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage() //if URL is changed when not looking @ screen.
        }
    }

}
