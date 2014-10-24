//
//  ViewController.swift
//  SoundRecorder
//
//  Created by Erika V. Miguel on 10/23/14.
//  Copyright (c) 2014 Erika V. Miguel. All rights reserved.
//

//TODO: Rename buttons, need to reconnect to viewcontroller ad disconnect

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
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
        

//        var paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
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
    //    if player.playing {
    //        player.stop()
    //    }
        
        if !recorder.recording {
            var session = AVAudioSession.sharedInstance()
            session.setActive(true, withOptions: nil, error: nil)
            recorder.record()
            recordButton.setTitle("Pause", forState: UIControlState.Normal)
        } else {
            recorder.pause()
            recordButton.setTitle("Record", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func stopTapped(sender: AnyObject) {
        recorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, withOptions: nil, error: nil)
        
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
            
            // ios8 and later
/*            var alert = UIAlertController(title: "Recorder",
                message: "Finished Recording",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Keep", style: .Default, handler: {action in
                println("keep was tapped")
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {action in self.recorder.deleteRecording()})) */
            
          //  self.presentViewController(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!,
        error: NSError!) {
            println("\(error.localizedDescription)")
    }
    
}


