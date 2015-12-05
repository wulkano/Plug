import XCPlayground
import Foundation
import Alamofire
import HypeMachineAPI

// Allow network requests to complete
XCPSetExecutionShouldContinueIndefinitely()

Alamofire.request(Router.Tracks.Index(nil))
    .responseCollection({(_,_, tracks: [Track]?, error) in
        println(tracks)
        println(error)
    })