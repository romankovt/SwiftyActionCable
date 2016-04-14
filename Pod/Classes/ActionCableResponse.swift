import SwiftyJSON

enum ActionCableResponseType {
    case Ping, ConfirmSubscription, ConfirmUnsubscription, Message
}

class ActionCableResponse {
    let plainResponse: String
    var type: ActionCableResponseType?
    var channel: String?
    var identifier: String?
    var message: JSON?
    
    init(plainResponse: String) {
        self.plainResponse = plainResponse
        parseResponse()
    }
    
    private func parseResponse() {
        if let data = self.plainResponse.dataUsingEncoding(NSUTF8StringEncoding) {
            let json = JSON(data: data)
            print(json)
            if json["identifier"].string! == "_ping" {
                // --- PING MESSAGE ---
                self.type = .Ping
            } else if json["type"].string != nil && json["type"].string! == "confirm_subscription" {
                // --- CONFIRM SUBSCRIPTION ---
                self.type = .ConfirmSubscription
                
                // set channel info
                if let plainText = json["identifier"].string {
                    if let data = plainText.dataUsingEncoding(NSUTF8StringEncoding) {
                        let subJson = JSON(data: data)
                        self.channel = subJson["channel"].string
                        self.identifier = plainText
                    }
                }
            } else if json["type"].string != nil && json["type"].string! == "confirm_unsubscription" {
                // --- CONFIRM UNSUBSCRIPTION ---
                self.type = .ConfirmUnsubscription
                // set channel info
                if let plainTextIdentifier = json["identifier"].string {
                    if let data = plainTextIdentifier.dataUsingEncoding(NSUTF8StringEncoding) {
                        self.identifier = plainTextIdentifier
                        
                        let subJson = JSON(data: data)
                        self.channel = subJson["channel"].string
                    }
                }
                
            } else if json["message"] != nil {
                // --- MESSAGE ---
                self.type = .Message
                
                // set channel
                if let plainTextIdentifier = json["identifier"].string {
                    if let data = plainTextIdentifier.dataUsingEncoding(NSUTF8StringEncoding) {
                        let subJson = JSON(data: data)
                        self.channel = subJson["channel"].string
                        self.identifier = plainTextIdentifier
                    }
                }
                
                // set json message
                self.message = json["message"]
            }
        }
    }
}
