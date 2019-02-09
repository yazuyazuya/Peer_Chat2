//
//  ViewController.swift
//  Multipeer_Chat2
//
//  Created by 大野和也 on 2019/02/09.
//  Copyright © 2019 yazuyazuya. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    let serviceType = "LCOC-Chat"
    
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID : MCPeerID!
    
    @IBOutlet weak var chatView1: UITextView!
    @IBOutlet weak var chatView2: UITextView!
    
    @IBOutlet weak var messageField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        self.browser = MCBrowserViewController(serviceType: serviceType, session: self.session)
        self.browser.delegate = self;
        self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        
        // tell the assistant to start advertising our fabulous chat
        self.assistant.start()
        
    }
    
    @IBAction func sendChat(_ sender: Any) {
        // Bundle up the text in the message field, and send it off to all connected peers
        
        let msg = self.messageField.text?.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        //var error : NSError?
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
            //try print("OK")
            
        } catch {
            print("Error sending data: \(String(describing: error.localizedDescription))")
        }
        
        self.updateChat(text: self.messageField.text!, fromPeer: self.peerID)
        
        self.messageField.text = ""
        
    }
    
    func updateChat(text: String, fromPeer peerID: MCPeerID) {
        // Appends some text to the chat view
        // If this peer ID is the local device's peer ID, then show the name as "Me"
        
        var name: String
        
        switch peerID {
        case self.peerID:
            name = "Me"
        //break
        default:
            name = peerID.displayName
        }
        
        // Add the name to the message and display it
        let message = "\(name) : \(text)\n"
        
        //self.chatView.text = self.chatView.text + message
        
        switch peerID {
        case self.peerID:
            self.chatView1.text = self.chatView1.text + message
        default:
            self.chatView2.text = self.chatView2.text + message
        }
        
    }
    
    @IBAction func showBrowser(_ sender: Any) {
        // Show the browser view controller
        self.present(self.browser, animated: true, completion: nil)
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is dismissed (ie the Done button was tapped)
        self.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        // Called when the browser view controller is cancelled
        self.dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Called when a peer sends an NSData to us
        // This needs to run on the main queue
        
        DispatchQueue.main.async {
            let msg = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            self.updateChat(text: msg! as String, fromPeer: peerID)
        }
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Called when a connected peer changes state (for example, goes offline)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Called when a peer establishes a stream with us
    }
    
    
    // The following methods do nothing, but the MCSessionDelegate protocol requires that we implement them.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Called when a peer starts sending a file to us
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Called when a file has finished transferring from another peer
    }
    
}

