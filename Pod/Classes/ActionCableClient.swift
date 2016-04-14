import SwiftWebSocket

class ActionCableClient {
    var channels:[ActionChannel] = []
    var ws: WebSocket
    var reconnectionWaitTime: Int64 = 5
    
    init(mutableRequest: NSMutableURLRequest) {
        ws = WebSocket(request: mutableRequest)
        setupCallbacks()
    }
    
    convenience init(cableURL: String) {
        let mutableRequest = NSMutableURLRequest(URL: NSURL(string: cableURL)!)
        self.init(mutableRequest: mutableRequest)
    }
    
    // close cable connection
    func disconnect() {
        ws.close()
        
        // unsubscribe from channels
        for channel in channels {
            channel.status = .NotConnected
        }
    }
    
    func subscribeTo(channel: ActionChannel, params: [String: AnyObject]? = nil) {
        self.channels.append(channel)
        // bind channel to the current WS instance
        channel.ws = ws
        
        if var params = params {
            // if there are params add channel name
            params["channel"] = channel.name
            
            if let identifier = ActionCableClient.serializeToJSONString(params) {
                channel.identifier = identifier
            }
        } else {
            // if there are no params, just use channel name as params
            if let identifier = ActionCableClient.serializeToJSONString(["channel": channel.name]) {
                channel.identifier = identifier
            }
        }
        
        if let subscribeParams =  ActionCableClient.serializeToJSONString(["command": "subscribe", "identifier": channel.identifier!]) {
            if ws.readyState == .Open {
                ws.send(subscribeParams)
            }
        }
    }
    
    func unsubscribeFrom(channel: ActionChannel) {
        if let identifier = channel.identifier {
            if let unsubscribeParams = ActionCableClient.serializeToJSONString(["command": "unsubscribe", "identifier": identifier]) {
                ws.send(unsubscribeParams)
            }
        }
    }
    
    static func serializeToJSONString(obj: AnyObject) -> String? {
        var jsonString: String?
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions.init(rawValue: 0))
            jsonString = String(data: jsonData, encoding: NSASCIIStringEncoding)
        } catch let error as NSError {
            print(error)
        }
        return jsonString
    }
    
    // on each message from a server - perform callback from appropriate ActionChannel
    private func setupCallbacks() {
        // skip pings
        ws.event.message = { message in
            if let plainText = message as? String {
                let response = ActionCableResponse.init(plainResponse: plainText)
                
                if let type = response.type, identifier = response.identifier where type != .Ping {
                    if let channel = self.findChannelBy(identifier) {
                        channel.handleResponse(response)
                    }
                }
            }
        }
        
        // when connects to socket subscribe all channels
        ws.event.open = {
            for channel in self.channels {
                if channel.status == .NotConnected {
                    channel.subscribe()
                }
            }
        }
        
        // try to reconnect to socket if fails
        ws.event.close = { _ in
            // close current one
            self.ws.close()
            
            // change channel statuses for subscribed channels
            for channel in self.channels where channel.status == .Subscribed {
                channel.status = .NotConnected
            }
            
            // try reopen every 5 sec by default
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), self.reconnectionWaitTime * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.ws.open() // reconnect to the previous connection
            }
        }
    }
    
    func findChannelBy(identifier: String) -> ActionChannel? {
        if let i = channels.indexOf({ $0.identifier == identifier }) {
            return channels[i]
        } else {
            return nil
        }
    }
}