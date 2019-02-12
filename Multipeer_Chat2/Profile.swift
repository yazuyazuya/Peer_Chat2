//
//  Profile.swift
//  Multipeer_Chat2
//
//  Created by 猪飼　立晟 on 2019/02/09.
//  Copyright © 2019年 yazuyazuya. All rights reserved.
//

import UIKit

class Profile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var enterName: UITextField!
    @IBOutlet weak var Profile_Image: UIImageView!
    
    @IBAction func saveImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    
    
    var fileURL: URL {
        let docsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return docsURL.appendingPathComponent("file.txt")
    }
    
    @IBAction func saveName(_ sender: Any) {
        try? enterName.text?.write(
            to: fileURL,
            atomically: true,
            encoding: .utf8
        )
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        // ビューに表示する
        self.Profile_Image.image = image
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.enterName.text = try? String(contentsOf: fileURL)
        Profile_Image.image = UIImage(named: "Image")
    }
    
}
