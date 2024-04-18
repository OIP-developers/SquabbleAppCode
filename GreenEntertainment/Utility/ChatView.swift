//
//  ChatView.swift
//  AthleteApp
//
//  Created by Abhishek Tyagi on 14/11/18.
//  Copyright © 2018 Uninterrupted. All rights reserved.
//


import Foundation
import UIKit

enum MessageType {
    case recieved
    case sent
    
    func color() -> UIColor {
        switch self {
        case .recieved:
            return RGBA(246, g: 246, b: 246, a: 1)
        case .sent:
            return RGBA(235, g: 36, b: 43, a: 1)
        }
    }
}

class ChatView: UIView {
    var messageType = MessageType.recieved
    let slantHeight: CGFloat = 8
    
    override func draw(_ rect: CGRect) {
      drawBackgroundShape(rect.size)
    }
    
    private func drawBackgroundShape(_ size: CGSize) {
        let width = size.width
        let height = size.height
        
        let bezierPath = UIBezierPath()
        
        if messageType == MessageType.recieved {
            bezierPath.move(to: CGPoint(x: 0, y: height))
            bezierPath.addLine(to: CGPoint(x: slantHeight, y: height - slantHeight))
            bezierPath.addLine(to: CGPoint(x: slantHeight, y: slantHeight))
            bezierPath.addCurve(to: CGPoint(x: slantHeight * 2, y: 0), controlPoint1: CGPoint(x: slantHeight, y: slantHeight), controlPoint2: CGPoint(x: slantHeight, y: 0))
            bezierPath.addLine(to: CGPoint(x: width - slantHeight, y: 0))
            bezierPath.addCurve(to: CGPoint(x: width, y: slantHeight), controlPoint1: CGPoint(x: width, y: 0), controlPoint2: CGPoint(x: width, y: slantHeight))
            bezierPath.addLine(to: CGPoint(x: width, y: height - slantHeight))
            bezierPath.addCurve(to: CGPoint(x: width - slantHeight, y: height), controlPoint1: CGPoint(x: width, y: height), controlPoint2: CGPoint(x: width - slantHeight, y: height))
            bezierPath.addLine(to: CGPoint(x: 0, y: height))
            bezierPath.close()
        } else {
            bezierPath.move(to: CGPoint(x: width, y: height))
            bezierPath.addLine(to: CGPoint(x: width - slantHeight, y: height - slantHeight))
            bezierPath.addLine(to: CGPoint(x: width - slantHeight, y: slantHeight))
            bezierPath.addCurve(to: CGPoint(x: width - slantHeight * 2, y: 0), controlPoint1: CGPoint(x: width - slantHeight, y: 0), controlPoint2: CGPoint(x: width - slantHeight * 2, y: 0))
            bezierPath.addLine(to: CGPoint(x: slantHeight, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 0, y: slantHeight), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 0, y: slantHeight))
            bezierPath.addLine(to: CGPoint(x: 0, y: height - slantHeight))
            bezierPath.addCurve(to: CGPoint(x: slantHeight, y: height), controlPoint1: CGPoint(x: 0, y: height), controlPoint2: CGPoint(x: slantHeight, y: height))
            bezierPath.addLine(to: CGPoint(x: width, y: height))
            bezierPath.close()
        }
        
        let fillColor = messageType.color()
        fillColor.setFill()
        bezierPath.fill()
    }
}

