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
        
        stopButton.enabled = false
        playButton.enabled = false
        
        var error: NSError?
        
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording-\(format.stringFromDate(NSDate.date())).m4a"
        println(currentFileName)
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen. want to do something about it?
            println("sound exists")
        }
        var recordSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        
        recorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings, error: &error)
        
        if let e = error {
            println(e.localizedDescription)
        } else {
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }
    }
    
    @IBAction func recordTapped(sender: AnyObject) {
        if player != nil && player.playing {
            player.stop()
        }
        
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
        
        // assuming that you can also stop the player
        if player != nil && player.playing {
            player.stop()
            println("player stopped")
        } else if recorder != nil && recorder.recording {
            recorder.stop()
            println("recorder stopped")
        }
        
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, withOptions: nil, error: nil)
        
    }
    
    @IBAction func playTapped(sender: AnyObject) {
        // disable record button while playing; will enable later
        recordButton.enabled = false
        stopButton.enabled = true
        
        var error: NSError?
        
        //initalize with recorder url
        player = AVAudioPlayer(contentsOfURL: recorder.url, error: nil)
        
        // if player doesn't exist for this file
        if player == nil {
            if let e = error {
                println(e.localizedDescription)  // ...not quite sure what this does
            }
        }
        
        if !recorder.recording{
            player.delegate = self
            player.prepareToPlay()
            //player.volume = 1.0
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
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!,
        successfully flag: Bool) {
            println("finished recording \(flag)")
            stopButton.enabled = false
            playButton.enabled = true
            recordButton.setTitle("Record", forState:.Normal)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        var alert = UIAlertView(title: "Done", message: "Finished Playing the recording", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!,
        error: NSError!) {
            println("\(error.localizedDescription)")
    }
    
}


