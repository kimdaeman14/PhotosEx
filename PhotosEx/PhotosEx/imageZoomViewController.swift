//
//  imageZoomViewController.swift
//  PhotosEx
//
//  Created by kimdaeman14 on 2018. 8. 3..
//  Copyright © 2018년 GoldenShoe. All rights reserved.
//

import UIKit
import Photos

class imageZoomViewController: UIViewController, UIScrollViewDelegate {

    var asset: PHAsset!
    let imageManager: PHCachingImageManager = PHCachingImageManager() //얘로이미지요청
    
    @IBOutlet weak var imageView:UIImageView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //에셋에서 이미지를 호출해달라.
        imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: nil) { image, _ in
            self.imageView.image = image
        }

    }
    
    
  

   

}
