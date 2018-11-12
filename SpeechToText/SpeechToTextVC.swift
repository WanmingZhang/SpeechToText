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

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var detectedText: UITextView!
    
    let audioEngine = AVAudioEngine()
    var speechRecognizer = SFSpeechRecognizer()
    var request: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask : SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        //speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh_Hans"))
        
        self.setupRecordButton()
    }
    
    func setupRecordButton() {
        
        if let speechRecognizer = speechRecognizer {
            
            speechRecognizer.delegate = self
            SFSpeechRecognizer.requestAuthorization { authStatus in
                // The callback may not happen on the main thread, make sure to update record button's state on main thread.
                DispatchQueue.main.async { // TODO: pop up alert instead
                    switch authStatus {
                    case .authorized:
                        self.recordButton.isEnabled = true
                        
                    case .denied:
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                        
                    case .restricted:
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                        
                    case .notDetermined:
                        self.recordButton.isEnabled = false
                        self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                    }
                }
            }
        }
    }
    
    private func startRecording() throws {
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record,
                                     mode: AVAudioSession.Mode.measurement,
                                     options: AVAudioSession.CategoryOptions.duckOthers)
        try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = request else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        if let recognizer = speechRecognizer {
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let strongSelf = self else { return }
                var isFinal = false
                if let result = result {
                    DispatchQueue.main.async {
                        let bestString = result.bestTranscription.formattedString
                        strongSelf.detectedText.text = bestString
                    }
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    strongSelf.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    strongSelf.request = nil
                    strongSelf.recognitionTask = nil
                    
                    strongSelf.recordButton.isEnabled = true
                    strongSelf.recordButton.setTitle("Start Recording", for: [])
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        detectedText.text = "(Go ahead, I'm listening)"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    // MARK: Interface Builder actions
    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            request?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
        } else {
            do {
               try startRecording()
               recordButton.setTitle("Stop recording", for: [])
            }
            catch {
                print(error)
            }
            
        }
    }
    
}
