//
//  TrimViewController.swift
//  Test150528
//
//  Created by 中原規之 on 2015/06/03.
//  Copyright (c) 2015年 中原規之. All rights reserved.
//

import UIKit

class TrimViewController: UIViewController {
    
    @IBOutlet weak var trimImageView: TrimImageView!
    @IBOutlet var trimView: TrimView!
    
    var orgImage:UIImage!
    var master: Master = Master()
    
    let trimFrameLayer:CALayer = CALayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.trimImageView.image = self.orgImage
        self.trimView.trimImageView = self.trimImageView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        self.trimView.master = self.master
        
        self.trimFrameLayer.frame = self.trimView.layer.bounds
        //self.trimFrameLayer.backgroundColor = UIColor.redColor().CGColor
        self.trimFrameLayer.delegate = self
        self.trimFrameLayer.contentsScale = UIScreen.mainScreen().scale
        self.trimView.layer.addSublayer(self.trimFrameLayer)
        self.trimView.trimFrameLayer = self.trimFrameLayer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.trimImageView.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: self.orgImage.size)
        //self.trimImageView.contentMode = UIViewContentMode.Center
        var scale:CGFloat = 1.0
        let frame_wh_rate:CGFloat = self.view.bounds.width / self.view.bounds.height
        let image_wh_rate:CGFloat = self.orgImage.size.width / self.orgImage.size.height
        if(frame_wh_rate < image_wh_rate) {
            scale = self.view.bounds.width / self.orgImage.size.width
        }
        else {
            scale = self.view.bounds.height / self.orgImage.size.height
        }
        
        NSLog("trimImageView.bounds w = %f h= %f", self.trimImageView.bounds.width, self.trimImageView.bounds.height)
        NSLog("trimImageView.frame w = %f h= %f", self.trimImageView.frame.width, self.trimImageView.frame.height)
        NSLog("view.bounds w = %f h= %f", self.view.bounds.width, self.view.bounds.height)
        NSLog("view.frame w = %f h= %f", self.view.frame.width, self.view.frame.height)
        NSLog("scale = %f", scale)

        self.trimView.extScale = scale
        let scaleTransform = CGAffineTransformMakeScale(scale, scale)
        let transitionTransform = CGAffineTransformMakeTranslation(0.0, 0.0)
        self.trimImageView.transform = CGAffineTransformConcat(scaleTransform, transitionTransform)        //self.trimImageView.clipsToBounds = true
        
        NSLog("trimImageView.bounds w = %f h= %f", self.trimImageView.bounds.width, self.trimImageView.bounds.height)
        NSLog("trimImageView.frame w = %f h= %f", self.trimImageView.frame.width, self.trimImageView.frame.height)
        NSLog("view.bounds w = %f h= %f", self.view.bounds.width, self.view.bounds.height)
        NSLog("view.frame w = %f h= %f", self.view.frame.width, self.view.frame.height)
        NSLog("scale = %f", scale)
        
        self.master.trimFrame.origin.x = self.trimImageView.frame.origin.x
        self.master.trimFrame.origin.y = self.trimImageView.frame.origin.y
        self.master.trimFrame.size.width = self.trimImageView.frame.size.width
        self.master.trimFrame.size.height = self.trimImageView.frame.size.height
        
        self.trimFrameLayer.setNeedsDisplay()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextViewController = segue.destinationViewController as! ViewController
        
        var size:CGSize = CGSizeMake(self.master.trimFrame.size.width,self.master.trimFrame.size.height)
        UIGraphicsBeginImageContext(size)
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        let affine_move_left_top:CGAffineTransform = CGAffineTransformMakeTranslation(
            -self.master.trimFrame.origin.x, -self.master.trimFrame.origin.y)
        CGContextConcatCTM(context, affine_move_left_top)
        self.view.layer.renderInContext(context)
        var dist_image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        nextViewController.orgImage = dist_image
    }

    
    func onOrientationChange(notification: NSNotification){
        /*
        var scale:CGFloat = 1.0
        let frame_wh_rate:CGFloat = self.trimImageView.frame.width / self.trimImageView.frame.height
        let image_wh_rate:CGFloat = self.orgImage.size.width / self.orgImage.size.height
        if(frame_wh_rate < image_wh_rate) {
            scale = self.trimImageView.frame.width / self.orgImage.size.width
        }
        else {
            scale = self.trimImageView.frame.height / self.orgImage.size.height
        }
        
        self.trimImageView.extScale = scale
        let scaleTransform = CGAffineTransformMakeScale(scale, scale)
        let transitionTransform = CGAffineTransformMakeTranslation(0.0, 0.0)
        self.trimImageView.transform = CGAffineTransformConcat(scaleTransform, transitionTransform)
        */
    }
    
    override func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
        if layer == self.trimFrameLayer {
            DrawUtil.rect(ctx,
                x: self.master.trimFrame.origin.x,
                y: self.master.trimFrame.origin.y,
                w: self.master.trimFrame.size.width,
                h: self.master.trimFrame.size.height,
                lineW: 1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
