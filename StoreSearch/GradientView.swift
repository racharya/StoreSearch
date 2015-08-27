//
//  GradientView.swift
//  StoreSearch
//
//  Created by Rachana Acharya on 8/25/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    //set the background color to fully transparent
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        autoresizingMask = .FlexibleWidth | .FlexibleHeight
    }
    
    //set the background color to fully transparent
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        autoresizingMask = .FlexibleWidth | .FlexibleHeightgs
        
    }
    
    //draws gradient on top of the transparent background
    override func drawRect(rect: CGRect) {
        //1. two arrays for color stops. (0,0,0,0.3) is first color(transparent black) that sits at location 0 (center of the screen)
        //(0,0,0,0.7) is a second color (also transparent black) that sits at location 1 (circumference of the gradient's circle)
        let components: [CGFloat] = [0,0,0,0.3,0,0,0,0.7]
        let locations: [CGFloat] = [0,1]// represents 0% and 100% opacity
        
        //2. create the gradient or new CGGradient object
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2)
        
        //3. figure out how big to draw the gradient object
        let x = CGRectGetMidX(bounds)//returns center points of a rectangle
        let y = CGRectGetMidY(bounds)//returns center points of a rectangle
        let point = CGPoint(x: x, y: y)
        let radius = max(x,y)
        
        //4. Finally drawing the thing
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawRadialGradient(context, gradient, point, 0, point, radius, CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation))
    }
}
