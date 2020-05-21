//
//	Constants.swift
//	Plug
//
//	Created by Alexander Marchant on 7/16/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation
import Alamofire

let ApiKey = Secrets.apiKey
let PlugErrorDomain = "Plug.ErrorDomain"
let RickRoll = false
let JSONResponseSerializerWithDataKey = "JSONResponseSerializerWithDataKey"

struct App {
	static let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
}
