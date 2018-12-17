//
//  ViewController.swift
//  Vision
//
//  Created by Ankit Jaiswal on 04/12/18.
//  Copyright © 2018 Ankit Jaiswal. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIAlertViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    private let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyC_fOhLeq_4radfL-CAtxroj9e0El41EgM")!
    var imageHeight: CGFloat = 0.0
    var imageWidth: CGFloat = 0.0
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func takePhotoButton(_ sender: Any) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        
        alert.addAction(cancelAction)
        //You must add this line then only in iPad it will not crash
        //alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Photo Actions
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            self.picker.sourceType = UIImagePickerController.SourceType.camera;
            self .present(self.picker, animated: true, completion: nil)
            self.picker.allowsEditing = false
            self.picker.delegate = self
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
            self.picker.sourceType = .savedPhotosAlbum
            self.picker.allowsEditing = false
            self.picker.delegate = self
            self.present(self.picker, animated: true, completion: nil)
        }
    }
    
    //    MARK: - Image Picker Delegate methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        httpPost()
    }
    
    func httpPost() {
        //        let imageData:NSData = imageView.image!.pngData() as! NSData
        //        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        
        let queryStringParam = ["key": "AIzaSyC_fOhLeq_4radfL-CAtxroj9e0El41EgM"]
        var urlComponent = URLComponents(string: "https://vision.googleapis.com/v1/images:annotate")!
        let queryItems = queryStringParam.map  { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponent.queryItems = queryItems
        //        let json: [String: Any] = [
        //            "requests": [
        //                [
        //                    "image" :
        //                        [
        //                                    "content": strBase64
        //                    ],
        //                    "features": [
        //                        "type": "DOCUMENT_TEXT_DETECTION"
        //                    ]
        //                ]
        //            ]
        //        ]
        
        let json: [String: Any] = [
            "requests": [
                [
                    "image" :
                        [
                            "source":
                                [
                                    "imageUri": "http://technophile.online:3002/images/uploads/f231d5bcebe61de473be57c4b0bcb5424f2afd6be490ad97b63f3082b628a701.JPG"
                            ]
                    ],
                    "features": [
                        "type": "DOCUMENT_TEXT_DETECTION"
                    ]
                ]
            ]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        var request = URLRequest(url: urlComponent.url!)
        request.httpMethod = "POST"
        request.setValue("json/application", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        URLSession.shared.getAllTasks { (openTasks: [URLSessionTask]) in
            NSLog("open tasks: \(openTasks)")
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (responseData: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let data = responseData else { return }
                
                let jsonall = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(jsonall)
                let welcome = try? JSONDecoder().decode(Welcome.self, from: data)
                if let obj = welcome {
                    self.calculate(obj)
                }
            } else {
                _ =  UIAlertController(title: "", message: error?.localizedDescription, preferredStyle: .alert)
            }
        })
        task.resume()
    }
    
    func calculate(_ welcome: Welcome) {
        let response = welcome.responses[0]
        let fullTextAnnotations = welcome.responses[0].fullTextAnnotation.pages[0]
        imageWidth = CGFloat(fullTextAnnotations.width)
        imageHeight = CGFloat(fullTextAnnotations.height)
        let buildboardArray = response.textAnnotations.filter { $0.description.uppercased() == "BUILDBOARD" }
            if buildboardArray.count == 1 {
                calculateCoordinates(buildboardArray.first!)
            } else {
                let buildboardArray = response.textAnnotations.filter { $0.description.uppercased().hasPrefix("BUILD") }
                if buildboardArray.count == 1 {
                    calculateCoordinates(buildboardArray.first!)
                } else if buildboardArray.count > 1 {
                    let buildboardArraySub = response.textAnnotations.filter { $0.description.uppercased().hasPrefix("BUILD") && $0.description.uppercased().hasSuffix("D") }
                    calculateCoordinates(buildboardArraySub.first!)
                }
                
        }
    }
    
    func calculateCoordinates(_ textAnnotation: TextAnnotation) {
        let vertices = textAnnotation.boundingPoly.vertices
        let topLeft = CGPoint(x: getX(CGFloat(vertices[0].x)), y: getY(CGFloat(vertices[0].y)))
        let topRight = CGPoint(x: getX(CGFloat(vertices[1].x)), y: getY(CGFloat(vertices[1].y)))
        let bottomLeft = CGPoint(x: getX(CGFloat(vertices[3].x)), y: getY(CGFloat(vertices[3].y)))
        let bottomRight = CGPoint(x: getX(CGFloat(vertices[2].x)), y: getY(CGFloat(vertices[2].y)))
        
        DispatchQueue.main.async {
            self.drawRect(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        }
    }
    
    func getX(_ pixels: CGFloat) -> CGFloat{
        let point = (SwifterSwift.screenWidth/imageWidth) * pixels
        
        return point
    }
    
    func getY(_ pixels: CGFloat) -> CGFloat {
        let point = (360/imageHeight) * pixels
        
        return point
    }
    
    func drawRect(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        let aPath = UIBezierPath()
        let line = CAShapeLayer()
        
        aPath.move(to: topLeft)
        
        aPath.addLine(to: topRight)
        aPath.addLine(to: bottomRight)
        aPath.addLine(to: bottomLeft)
        aPath.addLine(to: topLeft)
        
        //Keep using the method addLineToPoint until you get to the one where about to close the path
        
        line.path = aPath.cgPath
        line.strokeColor = UIColor.red.cgColor
        line.lineWidth = 2
        line.lineJoin = CAShapeLayerLineJoin.round
        line.fillColor = UIColor.clear.cgColor
        
        self.imageView.layer.addSublayer(line)
    }
}
