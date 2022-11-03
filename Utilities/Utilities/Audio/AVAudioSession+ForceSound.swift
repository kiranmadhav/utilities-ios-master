//
//  AVAudioSession+ForceSound.swift
//  Utilities
//
//  Created by Brooks, Jon on 4/3/20.
//  Copyright © 2020 Chien, Arnold. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAudioSession {
    /**
     Forces audio mode of `.playback` which will produce sound even if the phone
     is on silent mode, and begins the session.
     */
    static public func beginWithForcedSound() {
        // Force sound to play, even if the device's mute switch is on.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ as NSError {
            print("Error setting up AVAudioSession")
        }
    }

    static public func endSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ as NSError {
            print("Error ending up AVAudioSession")
        }
    }
}
