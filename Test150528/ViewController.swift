//
//  ViewController.swift
//  Test150528
//
//  Created by 中原規之 on 2015/05/28.
//  Copyright (c) 2015年 中原規之. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var mainImageView: UIImageView!
    
    var orgImage: UIImage!
    
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if self.orgImage != nil {
            self.mainImageView.image = self.orgImage
        }
        self.mainImageView.contentMode = UIViewContentMode.ScaleAspectFit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCameraButton(sender: AnyObject) {
        let upc: UIImagePickerController = UIImagePickerController()
        
        upc.delegate = self
        upc.allowsEditing = false
        if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front) {
            upc.sourceType = UIImagePickerControllerSourceType.Camera
        }
        else {
            upc.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        }
        
        self.presentViewController( upc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        //var image: UIImage! = info[UIImagePickerControllerEditedImage] as! UIImage
        var image: UIImage! = info[UIImagePickerControllerOriginalImage] as! UIImage
        if image != nil {
            self.orgImage = image
            self.mainImageView.image = image
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextViewController = segue.destinationViewController as! TrimViewController
        nextViewController.orgImage = self.orgImage
    }



}

