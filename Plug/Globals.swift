import Foundation
import Alamofire

let ApiKey = Secrets.apiKey
let PlugErrorDomain = "Plug.ErrorDomain"
let RickRoll = false
let JSONResponseSerializerWithDataKey = "JSONResponseSerializerWithDataKey"

enum App {
	static let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
}
