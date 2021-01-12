//
//  PhotoViewController.swift
//  Camera
//
//  Created by Sheryl Tay on 7/1/21.
//

import UIKit

class PhotoViewController: UIViewController {

    var takenPhoto: UIImage?
    
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let availableImage = takenPhoto {
            photo.image = availableImage
        }
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        if let availableImage = takenPhoto {
            UIImageWriteToSavedPhotosAlbum(availableImage, self, #selector(saveError), nil)
        }
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        let message = UIAlertController(title: "Photo successfully saved!", message: "You can continue taking photos", preferredStyle: .alert)
        
        message.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(message, animated: true)
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
