//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Chris Eadie on 05/08/2020.
//  Copyright © 2020 Chris Eadie Designs. All rights reserved.
//

import UIKit

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contectInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
