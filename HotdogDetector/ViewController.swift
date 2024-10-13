//
//  ViewController.swift
//  HotdogDetector
//
//  Created by Itai Melnik on 10/10/2024.
//test test

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView1: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        imageView1.image = image
        
        guard let ciimage = CIImage(image: image) else {
            fatalError("image could not convert to CIImage")
        }
        
        detect(image: ciimage)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("loading coreML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("no results")
            }
            
            if let firstResult = results.first {
                if firstResult.confidence > 0.6 && firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog Detected"
                    self.view.backgroundColor = .green
                    
                }
                else {
                    self.navigationItem.title = "No Hotdog Detected"
                    self.view.backgroundColor = .red
                }
                
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try! handler.perform([request])
        }
        catch{
            
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
    }
}

