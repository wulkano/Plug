//
//	Alamofire+responseImage.swift
//	Plug
//
//	Created by Alex Marchant on 5/14/15.
//	Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

// extension Alamofire.Request {
//	  public static func ImageResponseSerializer() -> DataResponse<NSImage> {
//		  return GenericResponseSerializer { response in
//			  guard let validData = data else {
//				  let failureReason = "Data could not be serialized. Input data was nil."
//				  let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
//				  return .Failure(data, error)
//			  }
//
//			  guard let image = NSImage(data: validData) else {
//				  let failureReason = "Image could not be serialized."
//				  let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
//				  return .Failure(data, error)
//			  }
//
//			  return .Success(image)
//		  }
//	  }
//
//	  public func responseImage(_ completionHandler: (NSURLRequest?, HTTPURLResponse?, Result<NSImage>) -> Void) -> Self {
//		  return response(responseSerializer: Request.ImageResponseSerializer(), completionHandler: completionHandler)
//	  }
// }

extension DataRequest {
	@discardableResult
	func responseImage(
		queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<NSImage>) -> Void
	) -> Self {
		let responseSerializer = DataResponseSerializer<NSImage> { _, _, data, error in
			guard error == nil else {
				return .failure(NSError())
			}

			guard
				let validData = data,
				let image = NSImage(data: validData)
			else {
				return .failure(NSError())
			}

			return .success(image)
		}

		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}
