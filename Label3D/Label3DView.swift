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
            let rxz = RandomFloat(min: 0, max: PI_2)
            let ry = RandomFloat(min: 0, max: PI_2)
//            let rz = RandomFloat(min: 0, max: PI_2)
            label.rxz = rxz
            label.ry = ry
//            label.rz = rz
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
        let (d_rx, _) = panGestureCallback(gesture)
        scrollX(d_rx)
//        scrollY(d_ry)
    }
    // 绕着y轴转，和xz平面的夹角变，但是ry不变
    func scrollX(th:Float) {
        for label in titles {
            label.rxz += th
        }
    }
    // TODO: 绕着x轴转，和yz平面的夹角变，但是rx不变
    func scrollY(th:Float) {
        for label in titles {
            label.ryz += th
        }
    }
}


class LabelSphere: UILabel {
    
    var cx:Float {
        didSet {
            setXZ()
        }
    }
    var cy:Float {
        didSet {
            setY()
        }
    }
    // 半径在xz平面上的投影和z轴之间的夹角
    var rxz:Float {
        didSet {
            setXZ()
        }
    }
    
    var ry:Float {
        didSet{
            setXZ()
            setY()
        }
    }

    var radius:Float {
        didSet{
            setXZ()
            setY()
            self.alpha = self.getAlpha()
        }
    }
    // 辅助属性：
    // 半径在yz平面上的投影和z轴之间的夹角
    var ryz:Float {
        get {
            let (_, py, pz) = getXYZ()
            return atan(py/pz)
        }
        set {
            let pyz = sin(rx) * radius
            let py = sin(ryz) * pyz
            let pz = cos(ryz) * pyz
            let px = cos(rx) * radius
            ry = asin(py/radius)
            rxz = atan(px/pz)
        }
    }
    var rx:Float {
        get {
            let (px, _, _) = getXYZ()
            return acos(px/radius)
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
        rxz = 0
        ry = 0
        cx = 0
        cy = 0
        radius = 0
        perspective = 10000
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        rxz = aDecoder.decodeFloatForKey("rxz")
        ry = aDecoder.decodeFloatForKey("ry")
        cx = aDecoder.decodeFloatForKey("cx")
        cy = aDecoder.decodeFloatForKey("cy")
        radius = aDecoder.decodeFloatForKey("radius")
        perspective = aDecoder.decodeFloatForKey("perspective")
        super.init(coder: aDecoder)
    }
    
    func setXZ() {
        let pxz = sin(ry) * radius
        self.layer.position.x = CGFloat(sin(rxz) * pxz + cx)
        let old_pz = self.layer.zPosition
        self.layer.zPosition = CGFloat(cos(rxz) * pxz)
        setTransform3D(self.layer.zPosition - old_pz)
        self.alpha = self.getAlpha()
    }
    
    func getXYZ() -> (Float, Float, Float) {
        let pxz = sin(ry) * radius
        let px = sin(rxz) * pxz
        let pz = cos(rxz) * pxz
        
        return (px, cos(ry)*radius, pz)
    }
    
    func setY() {
        self.layer.position.y = CGFloat(cos(ry) * radius + cy)
    }
    func setTransform3D(dz:CGFloat) {
        let t = self.layer.transform
        self.layer.transform = CATransform3DTranslate(t, 0, 0, dz)
    }
    func getAlpha() -> CGFloat {
        var alpha = 2*self.layer.zPosition/CGFloat(perspective) + 0.5
        alpha = min(1.0, alpha)
        alpha = max(0.1, alpha)
        return alpha
    }
}

public func RandomFloat(min min: Float, max: Float) -> Float {
    return (Float(arc4random()) / Float(UInt32.max)) * (max - min) + min
}