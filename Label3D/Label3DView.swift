//
//  Label3DView.swift
//  Label3DTest
//
//  Created by flybywind on 15/12/29.
//  Copyright © 2015年 flybywind. All rights reserved.
//

import UIKit

public class Label3DView: UIView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let panGesture = UIPanGestureRecognizer(target: self, action: "handelPan:")
        self.addGestureRecognizer(panGesture)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var perspective:Float = 2000
    public var fontSize:CGFloat = 15
    public var fontColor:UIColor = UIColor.blackColor()
    public var sphereRadius:Float = 0.5
    
    var titles = [LabelSphere]()
    
    public func loadLabelsFromFile(fpath:String) {
        if let content = try? String(contentsOfFile: fpath, usedEncoding: nil) {
            let lines = content.componentsSeparatedByString("\n")
            for t in lines {
                let label = LabelSphere(text: t)
                label.textAlignment = .Center
                titles.append(label)
            }
        }
    }
    
    public func resetLabelOnView() {
        let PI_2 = Float(M_PI*2)
        let cx = Float(self.frame.width/2)
        let cy = Float(self.frame.height/2)
        for label in titles {
            label.perspective = perspective
            label.font = UIFont.systemFontOfSize(fontSize)
            label.textColor = fontColor
            label.sizeToFit()
            let rx = RandomFloat(min: 0, max: PI_2)
            let ry = RandomFloat(min: 0, max: PI_2)
            let rz = RandomFloat(min: 0, max: PI_2)
            label.rx = rx
            label.ry = ry
            label.rz = rz
            label.cx = cx
            label.cy = cy
            label.radius = sphereRadius*perspective
            
            self.addSubview(label)
        }
    }
    // 可以继承该函数，修改旋转速度
    public func panGestureCallback(gesture: UIPanGestureRecognizer) ->(Float,Float) {
        let point = gesture.translationInView(self)
        
        let d_rx = Float(point.x/self.frame.width)
        let d_ry = Float(point.y/self.frame.height)
        
        return (d_rx, d_ry)
    }
    func handelPan(gesture: UIPanGestureRecognizer) {
        let (d_rx, d_ry) = panGestureCallback(gesture)
        scrollX(d_rx)
        scrollY(d_ry)
    }

    func scrollX(th:Float) {
        for label in titles {
            label.rx -= th
            label.rz += th
        }
    }
    func scrollY(th:Float) {
        for label in titles {
            label.ry -= th
            label.rz += th
        }
    }
}


class LabelSphere: UILabel {
    
    var cx:Float {
        didSet {
            self.layer.position.x = CGFloat(cos(rx) * radius + cx)
        }
    }
    var cy:Float {
        didSet {
            self.layer.position.y = CGFloat(cos(ry) * radius + cy)
        }
    }
    
    var rx:Float {
        didSet {
            self.layer.position.x = CGFloat(cos(rx) * radius + cx)
        }
    }
    var ry:Float {
        didSet{
            self.layer.position.y = CGFloat(cos(ry) * radius + cy)
        }
    }
    var rz:Float {
        didSet{
            let pz = CGFloat(cos(rz)*radius)
            let old_pz = CGFloat(cos(oldValue)*radius)
            self.layer.zPosition = pz
            
            self.setTransform3D(pz - old_pz)
            self.alpha = self.getAlpha()
        }
    }
    var radius:Float {
        didSet{
            self.layer.position.x = CGFloat(cos(rx) * radius + cx)
            self.layer.position.y = CGFloat(cos(ry) * radius + cy)

            let pz = CGFloat(cos(rz)*radius)
            let old_pz = CGFloat(cos(rz)*oldValue)
            self.layer.zPosition = pz
            
            self.setTransform3D(pz - old_pz)
            self.alpha = self.getAlpha()
        }
    }
    
    var perspective:Float {
        didSet {
            self.layer.transform.m34 = CGFloat(-1.0/perspective)
            self.alpha = self.getAlpha()
        }
    }
    
    convenience init(text:String) {
        self.init()
        self.text = text
    }
    override init(frame: CGRect) {
        rx = 0
        ry = 0
        rz = 0
        cx = 0
        cy = 0
        radius = 0
        perspective = 10000
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        rx = aDecoder.decodeFloatForKey("rx")
        ry = aDecoder.decodeFloatForKey("ry")
        rz = aDecoder.decodeFloatForKey("rz")
        cx = aDecoder.decodeFloatForKey("cx")
        cy = aDecoder.decodeFloatForKey("cy")
        radius = aDecoder.decodeFloatForKey("radius")
        perspective = aDecoder.decodeFloatForKey("perspective")
        super.init(coder: aDecoder)
    }
    
    func setTransform3D(dz:CGFloat) {
        let t = self.layer.transform
        self.layer.transform = CATransform3DTranslate(t, 0, 0, dz)
    }
    func getAlpha() -> CGFloat {
        var alpha = 2*self.layer.zPosition/CGFloat(perspective) + 0.5
        alpha = min(1.0, alpha)
        alpha = max(0, alpha)
        return alpha
    }
}

public func RandomFloat(min min: Float, max: Float) -> Float {
    return (Float(arc4random()) / Float(UInt32.max)) * (max - min) + min
}