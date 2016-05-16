//
//  ViewController.swift
//  SwiftActionCableClient
//
//  Created by Roman Kovtunenko on 04/14/2016.
//  Copyright (c) 2016 Roman Kovtunenko. All rights reserved.
//

import UIKit
import SwiftyActionCable

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiate client with NSMutableURLRequest
        let request = NSMutableURLRequest(URL: NSURL(string: "ws://localhost:3000/cable")!)
        let client = ActionCableClient(mutableRequest: request)
        
        // Create new channel
        let exampleChannel = ActionChannel.init(name: "ExampleChannel")
        
        // callback on message from server
        exampleChannel.onMessage = { json in
            print(json)
            // send unsubscribe event to the server
            client.unsubscribeFrom(exampleChannel)
        }
        
        // callback on succesfull subsbscription
        exampleChannel.onSubscribed  = {
            print("succesfully subscribed!")
        }
        
        // send subscribe to request to server and start listening
        client.subscribeTo(exampleChannel)
        exampleChannel.perform("say_hello")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

