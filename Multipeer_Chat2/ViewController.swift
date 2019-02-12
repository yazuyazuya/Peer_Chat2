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

var imageURL: URL {
    let docsURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
        )[0]
    return docsURL.appendingPathComponent("file.png")
}

class SendData{
    func sendName() -> String {
        let file_name: String? = try? String(contentsOf: fileURL)
        let name = (file_name != nil && file_name != "") ? file_name! : "noname"
        return name
    }
    
    func sendImage() -> UIImage {
        let file_image: UIImage? = UIImage(contentsOfFile: imageURL.path)
        let image = (file_image != nil) ? file_image! : UIImage(named: "Image")!
        return image
    }
}

var sendData: SendData = SendData()



class ViewController: UIViewController, MCNearbyServiceBrowserDelegate, MCSessionDelegate,  MCNearbyServiceAdvertiserDelegate{
    
    var talks: [String] = []
    
    let serviceType = "LCOC-Chat"
    var browser : MCNearbyServiceBrowser!
    var assistant : MCNearbyServiceAdvertiser!
    var session : MCSession!
    var peerID : MCPeerID!
    
    @IBOutlet weak var chatView1: UITextView!
    @IBOutlet weak var messageField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(sendData)
        //self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.peerID = MCPeerID(displayName: sendData.sendName())
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
        
        let msg = (sendData.sendName() + " : " + self.messageField.text!).data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        //var error : NSError?
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
            //try print("OK")
            
        } catch {
            print("Error sending data: \(String(describing: error.localizedDescription))")
        }
        
        self.updateChat(text: sendData.sendName() + " : " + self.messageField.text!, fromPeer: self.peerID)
        
        self.messageField.text = ""
        
    }
    
    func updateChat(text: String, fromPeer peerID: MCPeerID) {
        // Appends some text to the chat view
        // If this peer ID is the local device's peer ID, then show the name as "Me"
        
        
        // Add the name to the message and display it
        self.talks.append(text + "\n")
        
        var str = NSMutableAttributedString()
        
        let attachment = NSTextAttachment()
        attachment.image = sendData.sendImage()
        let strImage = NSAttributedString(attachment: attachment)
        
        attachment.bounds = CGRect(x: 0, y: -4, width: 32, height: 32)
        for value in self.talks {
            let strText = NSAttributedString(string: value)
            str.insert(strImage, at: str.length)
            str.insert(strText, at: str.length)
        }
        
        //self.chatView.text = self.chatView.text + message
        self.chatView1.attributedText = str
        
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

