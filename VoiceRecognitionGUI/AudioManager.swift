//
//  AudioManager.swift
//  VoiceRecognitionGUI
//
//  Created by Dawid Walenciak on 08/10/2020.
//  Copyright © 2020 Dawid Walenciak. All rights reserved.
//

import AVFoundation

class AudioManager: ObservableObject {
    
    var audioPlayer : AVAudioPlayer!
    var audioRecorder : AVAudioRecorder!
    var audioSession : AVAudioSession!
    
    var audioFileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("recordedAudio.m4a")
    
    deinit {
        try? FileManager.default.removeItem(at: audioFileUrl)
    }
    
    func playAudioClip() {
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func startRecordingAudioClip() {
        let recordingSettings = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey : 12000,
            AVNumberOfChannelsKey : 1,
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
        ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFileUrl, settings: recordingSettings)
            
            self.audioRecorder.record()
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func stopRecordingAudioClip() {
        self.audioRecorder.stop()
    }
    
    func initializeSession() -> Bool {
        var returnValue = false
        do {
            self.audioSession = AVAudioSession.sharedInstance()
            try self.audioSession.setCategory(.playAndRecord)
            
            self.audioSession.requestRecordPermission { (selectedOption) in
                if(!selectedOption) {
                    returnValue.toggle()
                }
                
            }
        }
        catch{
            print(error.localizedDescription)
        }
        
        return returnValue
    }
    
}
