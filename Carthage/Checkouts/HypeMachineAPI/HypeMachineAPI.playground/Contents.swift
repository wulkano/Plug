import XCPlayground
import Foundation
import HypeMachineAPI


// Allow network requests to complete
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

func callback(result: Result<[Blog]>) {
    print(result.value!.filter { $0.following == true }.count)
    print(result.value!.filter { $0.featured == true }.count)
}

HypeMachineAPI.Requests.Blogs.index(optionalParams: nil, callback: callback)