import Foundation
import Alamofire

extension DataRequest {
	@discardableResult
	func responseImage(
		queue: DispatchQueue? = nil,
		completionHandler: @escaping (DataResponse<NSImage>) -> Void
	) -> Self {
		let responseSerializer = DataResponseSerializer<NSImage> { _, _, data, error in
			guard error == nil else {
				return .failure(NSError()) // swiftlint:disable:this discouraged_direct_init
			}

			guard
				let validData = data,
				let image = NSImage(data: validData)
			else {
				return .failure(NSError()) // swiftlint:disable:this discouraged_direct_init
			}

			return .success(image)
		}

		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}
