//
//  MiscRouter.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Router {
    public enum Misc: URLRequestConvertible {
        
        case GetToken(String, String)
        
        var method: Alamofire.Method {
            switch self {
            case .GetToken:
                return .POST
            }
        }
        
        var path: String {
            switch self {
            case .GetToken:
                return "/get_token"
            }
        }
        
        var params: [String: AnyObject]? {
            switch self {
            case .GetToken(let usernameOrEmail, let password):
                return [
                    "username": usernameOrEmail,
                    "password": password,
                    "device_id": DeviceID(),
                ]
            }
        }
        
        public var URLRequest: NSMutableURLRequest {
            return Router.URLRequest(method: method, path: path, params: params)
        }
        
        
        func DeviceID() -> String {
            // Should probably hash the serial number instead of just adding 0's
            var deviceID: String
            let deviceIDLength = 16
            
            deviceID = GetSerialNumber()!
            let pad = deviceIDLength - deviceID.characters.count
            
            for _ in 1...pad {
                deviceID = deviceID + "0"
            }
            
            return deviceID
        }
        
        func GetSerialNumber() -> String? {
            var serial: String? = nil
            var platformExpert: io_service_t?
            
            platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
            
            if platformExpert != nil {
                serial = IORegistryEntryCreateCFProperty(platformExpert!, kIOPlatformSerialNumberKey, kCFAllocatorDefault, 0).takeRetainedValue() as? String
                IOObjectRelease(platformExpert!)
            }
            
            return serial
        }
    }
}