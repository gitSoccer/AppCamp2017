//
//  ImageManipulation.swift
//  CacheMeIfYouCan
//
//  Created by “Camp on 6/27/17.
//  Copyright © 2017 Ethan Rosenfeld. All rights reserved.
//

import UIKit

class ImageManipulation: NSObject
{
    static func prepareImageAsAnnotation(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight * 2))
        
        let context = UIGraphicsGetCurrentContext()!
        
        let color = UIColor(red: 243/255.0, green: 146/255.0, blue: 36/255.0, alpha: 255).cgColor
        context.setFillColor(color)
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: 0, y: newHeight * 0.8))
        context.addLine(to: CGPoint(x: newWidth * 0.5, y: newHeight))
        context.addLine(to: CGPoint(x: newWidth, y: newHeight * 0.8))
        context.addLine(to: CGPoint(x: newWidth, y: 0))
        context.addLine(to: CGPoint(x: 0, y: 0))
        context.fillPath()

        image.draw(in: CGRect(x: newWidth * 0.1, y: newHeight * 0.05, width: newWidth * 0.8, height: newHeight * 0.7))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    static func prepareImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
//    static func prepareImage(image: UIImage, newWidth: CGFloat) -> UIImage
//    {
//        let scale = newWidth / image.size.width
//        let newHeight = image.size.height * scale
//        
//        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight * 2))
//        
//        image.draw(in: CGRect(x: newWidth, y: newHeight, width: newWidth, height: newHeight))
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext()
//        
//        return newImage!
//    }
}
