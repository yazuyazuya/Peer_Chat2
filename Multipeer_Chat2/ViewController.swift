//
//  ViewController.swift
//  Multipeer_Chat2
//
//  Created by 大野和也 on 2019/02/09.
//  Copyright © 2019 yazuyazuya. All rights reserved.
//

import UIKit
import MultipeerConnectivity

var fileURL: URL {
    let docsURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
        )[0]
    return docsURL.appendingPathComponent("file.txt")
}

class SendData{
    var name : String
    init (){
        let name : String? = try? String(contentsOf: fileURL)
        self.name = (name != nil && name != "") ? name! : "noname"
    }
}

class ViewController: UIViewController, MCNearbyServiceBrowserDelegate, MCSessionDelegate,  MCNearbyServiceAdvertiserDelegate{
    let serviceType = "LCOC-Chat"
    var Name : String?
    var browser : MCNearbyServiceBrowser!
    var assistant : MCNearbyServiceAdvertiser!
    var session : MCSession!
    var peerID : MCPeerID!
    var sendData = SendData()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendData = SendData()
    }
    

    
    @IBOutlet weak var chatView1: UITextView!
    @IBOutlet weak var messageField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.peerID = MCPeerID(displayName: self.sendData.name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        self.browser.delegate = self
        self.browser.startBrowsingForPeers()
        
        self.assistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        self.assistant.delegate = self
        self.assistant.startAdvertisingPeer()
        // tell the assistant to start advertising our fabulous chat
        
    }
    
    @IBAction func sendChat(_ sender: Any) {
        // Bundle up the text in the message field, and send it off to all connected peers
        
        let msg = (self.sendData.name + " : " + self.messageField.text!).data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        //var error : NSError?
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
            //try print("OK")
            
        } catch {
            print("Error sending data: \(String(describing: error.localizedDescription))")
        }
        
        self.updateChat(text: self.sendData.name + " : " + self.messageField.text!, fromPeer: self.peerID)
        
        self.messageField.text = ""
        
    }
    
    func updateChat(text: String, fromPeer peerID: MCPeerID) {
        // Appends some text to the chat view
        // If this peer ID is the local device's peer ID, then show the name as "Me"
        
        
        // Add the name to the message and display it
        let message = "\(text)\n"
        
        //self.chatView.text = self.chatView.text + message
        self.chatView1.text = self.chatView1.text + message
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("error")
    }
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.browser.invitePeer(peerID, to: session, withContext: nil, timeout: 60)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
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

