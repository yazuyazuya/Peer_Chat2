//
//  Profile.swift
//  Multipeer_Chat2
//
//  Created by 猪飼　立晟 on 2019/02/09.
//  Copyright © 2019年 yazuyazuya. All rights reserved.
//

import UIKit

class Profile: UIViewController {
    
    @IBOutlet weak var enterName: UITextField!
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.enterName.text = try? String(contentsOf: fileURL)
    }
    
}
