//
//  ViewController.swift
//  SoundRecorder
//
//  Created by Erika V. Miguel and Jessica Mann on 10/23/14.
//  Copyright (c) 2014 Erika V. Miguel and Jessica Mann. All rights reserved.
//


import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var recorder : AVAudioRecorder!
    var player : AVAudioPlayer!
    var soundFileURL:NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setup()
    }
    
    func setup() {
        // disable stop & play button since nothing has been recorded
        stopButton.enabled = false
        playButton.enabled = false
    
        // recorded file named with time stamp
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording-\(format.stringFromDate(NSDate.date())).m4a"
        
        // for capturing error information
        var error: NSError?
        
        // setup path to save file
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        // make sure sound file exists
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen. want to do something about it?
            println("sound exists")
        }
        
        // initialize sound output format
        var recordSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        
        // initialize recorder object
        recorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings, error: &error)
        
        // if there is error, print out the stack trace; else, prepare to record
        if let e = error {
            println(e.localizedDescription)
        } else {
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }

    }
    
    // if recrod button is tapped
    @IBAction func recordTapped(sender: AnyObject) {
        // if the player is playing, stop the player before recording
        if player != nil && player.playing {
            player.stop()
        }
        
        // if the recorder is currently recording, then pause
        // if the recorder is not recording, then start recording
        if !recorder.recording {
            var session = AVAudioSession.sharedInstance()
            session.setActive(true, withOptions: nil, error: nil)
            recorder.record()
            recordButton.setTitle("Pause", forState: UIControlState.Normal)
        } else {
            recorder.pause()
            recordButton.setTitle("Record", forState: UIControlState.Normal)
        }
        
        stopButton.enabled = true
    }
    
    @IBAction func stopTapped(sender: AnyObject) {
        
        // stop whatever is going on
        if player != nil && player.playing {
            player.stop()
            println("player stopped")
        } else if recorder != nil && recorder.recording {
            recorder.stop()
            println("recorder stopped")
        }
        
        // stop current audio session
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, withOptions: nil, error: nil)
        
    }
    
    @IBAction func playTapped(sender: AnyObject) {
        // disable record button while playing
        stopButton.enabled = true
        
        var error: NSError?
        
        //initalize with recorder url
        player = AVAudioPlayer(contentsOfURL: recorder.url, error: nil)
        
        // if player doesn't exist for this file, print out stack trace
        if player == nil {
            if let e = error {
                println(e.localizedDescription)
            }
        }
        
        // make sure recorder is not recording
        if !recorder.recording{
            player.delegate = self
            player.play()
            println("playing!")
        }
        
        // enable record button
        recordButton.enabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // delegate protocol that MUST be implemented for AVAudioRecorder
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!,
        successfully flag: Bool) {
            println("finished recording \(flag)")
            stopButton.enabled = false
            playButton.enabled = true
            recordButton.setTitle("Record", forState:.Normal)
    }
    
    // delegate protocol that MUST be implemented for AVAudioRecorder
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!,
        error: NSError!) {
            println("\(error.localizedDescription)")
    }
    
    // delegate protocol that MUST be implemented for AVAudioPlayer
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        var alert = UIAlertView(title: "Done", message: "Finished Playing the recording", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    
}


