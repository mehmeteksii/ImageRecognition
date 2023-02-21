//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Mehmet Ekşi on 17.02.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var chosenImage = CIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    
    @IBAction func changeClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
            
        }
        
        recognizeImage(image: chosenImage)
    }
   
    func recognizeImage(image: CIImage){
        
        // 1) Request
        // 2) Handler
        
        resultLabel.text = "Finding ..."
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                if let results = vnrequest.results as? [VNClassificationObservation]{
                    
                    if results.count > 0 {
                        let topResults = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResults?.confidence ?? 0) * 100
                            
                            let rounded = Int(confidenceLevel * 100) / 100
                            
                            self.resultLabel.text = "\(rounded)% it's \(topResults!.identifier)"
                        }
                    }
                    
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async{
                do{
                    try handler.perform([request])
                }catch{
                    print("Error")
                }
                
            }
            
        }
        
    }
    
}

