//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Chris Eadie on 13/08/2020.
//  Copyright © 2020 Chris Eadie Designs. All rights reserved.
//

import UIKit

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(save-Error), nil)
    }
    
    @objc func saveError(_ image:UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // Save complete
    }
}
