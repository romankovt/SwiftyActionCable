import SwiftyJSON
import SwiftWebSocket

public enum ActionChannelStatus {
    case NotConnected, Subscribed, Unsubscribed
}

public class ActionChannel {
    public var name: String
    public var identifier: String?
    public var status = ActionChannelStatus.NotConnected
    // if callback was performed when channel was not connected it puts it into a que and waits reconnection
    private var performQue = [String]()
    // called when gets "confirm_subscription" from server
    public var onSubscribed: (() -> ())?
    // called when gets message for this channel
    public var onMessage: ((JSON) -> ())?
    public var ws: WebSocket?
    
    public init(name: String) {
        self.name = name
    }
        
    public convenience init(name: String, onMessage: ((JSON) -> ())) {
        self.init(name: name)
        self.onMessage = onMessage
    }
    
    // Perform method on a back-end side
    public func perform(channelName: String, methodName: String) {
        if let identifier = self.identifier {
            let paramsObj = ["command": "message", "identifier": identifier, "data": "{\"action\": \"\(methodName)\"}"]
            if let messageParams = ActionCableClient.serializeToJSONString(paramsObj) {
                if status == .NotConnected {
                    // if there is perform while channel is not connected yet put it in a que
                    performQue.append(messageParams)
                } else if status == .Subscribed {
                    ws?.send(messageParams)
                }
            }
        }
    }
    
    public func subscribe() {
        if let subscribeParams = ActionCableClient.serializeToJSONString(["command": "subscribe", "identifier": identifier!]) {
            if ws?.readyState == .Open {
                ws?.send(subscribeParams)
            }
        }
    }

    func handleResponse(response: ActionCableResponse) {
        if response.type == .ConfirmSubscription {
            // when system message just change channel status
            self.status = .Subscribed
            
            // execute commands from the que
            for command in performQue {
                ws?.send(command)
            }
            
            // execute subscribed callback
            if let subscribedCallback = onSubscribed {
                subscribedCallback()
            }
        } else if response.type == .ConfirmUnsubscription {
            self.status = .Unsubscribed
            
            // TO DO: add unsubscribe callback suppport
        } else if response.type == .Message {
            // if there is a message from the server perform a custom handler
            if let message = response.message {
                if let onMessage = onMessage {
                    onMessage(message)
                }
            }
        }
    }
}
