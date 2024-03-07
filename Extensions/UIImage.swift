//
//  UIImage.swift
//  pint pilot
//
//  Created by Karl Cridland on 28/11/2020.
//

import Foundation
import UIKit

extension UIImage{
    
    func compress(_ percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            a in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func compress() -> UIImage{
        var compressed = self
        while compressed.pngData()!.count > 2 * 1024 * 1024{
            compressed = compressed.compress(0.5)!
        }
        return compressed
    }
    
    func maskWithColor(_ background: CGColor, _ maskImage: CIImage) -> UIImage? {
        
        // Removes the background color of an image.
        
        let bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitmapContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        bitmapContext!.clip(to: bounds, mask: CIContext(options: nil).createCGImage(maskImage, from: maskImage.extent)!)
        bitmapContext!.setFillColor(background)
        bitmapContext!.fill(bounds)
    
        if let cImage = bitmapContext!.makeImage() {
            let coloredImage = UIImage(cgImage: cImage)
        
            return coloredImage
        
        }
        
        return self
    }
    
    class func colorForNavBar(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    var scaledToSafeUploadSize: UIImage? {
        let maxImageSideLength: CGFloat = 480

        let largerSide: CGFloat = max(size.width, size.height)
        let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
        let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)

        return image(scaledTo: newImageSize)
    }

    func image(scaledTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }

        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func image(resizedTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}
