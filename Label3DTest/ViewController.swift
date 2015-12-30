//
//  ViewController.swift
//  Label3DTest
//
//  Created by flybywind on 15/12/29.
//  Copyright © 2015年 flybywind. All rights reserved.
//

import UIKit
import Label3D

class ViewController: UIViewController {

    var label3dView: Label3DView?
    let fm = NSFileManager.defaultManager()
    let bundle = NSBundle.mainBundle()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var frame = self.view.frame
        let width = frame.width*0.8
        let height = width
        let px = (frame.width - width)/2
        let py = (frame.height - height)/2
        frame = CGRect(x:px, y:py, width: width, height: height)
        label3dView = Label3DView(frame: frame)
        label3dView?.layer.backgroundColor = UIColor.blackColor().CGColor
        self.view.addSubview(label3dView!)
        if let fpath = bundle.pathForResource("108", ofType: "txt") {
            label3dView?.loadLabelsFromFile(fpath)
            label3dView?.perspective = Float(width)
            label3dView?.fontColor = UIColor.yellowColor()
            label3dView?.sphereRadius = 0.3
            label3dView?.fontSize = 25
            label3dView?.resetLabelOnView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

