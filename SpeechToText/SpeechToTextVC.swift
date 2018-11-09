//
//  SpeechToTextVC.swift
//  SpeechToText
//
//  Created by Zhang, Wanming - (p) on 11/9/18.
//  Copyright © 2018 ClaireZhang. All rights reserved.
//

import UIKit
import Speech

class SpeechToTextVC: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var detectedText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
