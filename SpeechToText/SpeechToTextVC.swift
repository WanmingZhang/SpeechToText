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
    
    let audioEngine = AVAudioEngine()
    var speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask : SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        //speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh_Hans"))
        
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        self.recordAndRecognizeSpeech()
    }
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch  {
            return print(error)
        }
        
        guard let myRecognizer = speechRecognizer else {
            return
        }
        guard myRecognizer.isAvailable else {
            return
        }
        
        recognitionTask = myRecognizer.recognitionTask(with: request, resultHandler: { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let result = result else {
                print("no speech to text result")
                return
            }
            
            DispatchQueue.main.async {
                let bestString = result.bestTranscription.formattedString
                strongSelf.detectedText.text = bestString
                strongSelf.stopAndCleanupAudioEngine()
            }
        })
    }
    
    func stopAndCleanupAudioEngine() {
        audioEngine.stop()
        request.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}
