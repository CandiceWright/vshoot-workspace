//
//  VotographerBasicViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 3/24/20.
//  Copyright © 2020 Candice Wright. All rights reserved.
//

import UIKit

class VotographerBasicViewController: UIViewController {
    
    var accessToken = ""
    var vshootId: NSInteger = 0
    var roomName:String = ""
    //new capture session attributes for photos
    var captureSession = AVCaptureSession()
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var position: AVCaptureDevice.Position?
    var photoOutput: AVCapturePhotoOutput!
    var cameraPosition = AVCaptureDevice.Position.back
    
    // Configure remote URL to fetch token from
    var tokenUrl = "http://localhost:8000/token.php"
    
    // Video SDK components
    var room: Room?
    var camera: CameraSource?
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?
    var remoteParticipant: RemoteParticipant?
    var remoteView: VideoView?
    
    // Conference state.
    var screenTrack: LocalVideoTrack?
    var videoSource: ReplayKitVideoSource?
    var conferenceRoom: Room?
    var videoPlayer: AVPlayer?
    
    let recorder = RPScreenRecorder.shared()
    
    // An application has a much higher memory limit than an extension. You may choose to deliver full sized buffers instead.
    static let kDownscaleBuffers = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
