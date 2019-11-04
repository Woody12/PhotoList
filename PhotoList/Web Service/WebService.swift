//
//  WebService.swift
//  PhotoList
//
//  Created by Woody Lee on 7/19/19.
//  Copyright © 2019 Woody Lee. All rights reserved.
//

import Foundation

enum NetworkError: Error {
	case DataReadFail
	case PopulateFail
}

struct Resource<T: Codable> {
	var urlString: String
	var method: String
}

class WebService {
	
	private let key = "0fe1aaa149e2cd9cfae6d59c927e453f"
	
	public func loadPhoto<T>(resource: Resource<T>, completion: @escaping (Result<T, NetworkError>) -> Void) {
		
		let postData = Data(base64Encoded: "{}".data(using: .utf8)!)
		let url = resource.urlString + key
	
		var request = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
		
		request.httpMethod = resource.method
		request.httpBody = postData
		
		// Invoke the Web service
		URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
			
			// Check for error
			guard let data = data,
				let jsonData = try? (JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as? [String: Any]),
				let jsonPhotosData = jsonData["photos"] as? [String: Any],
				let jsonPhotoData = jsonPhotosData["photo"],
				let jsonPhotoObject = try? JSONSerialization.data(withJSONObject: jsonPhotoData, options: .prettyPrinted)
			else {
				completion(.failure(.DataReadFail))
				return
			}
			
			// Populate to Model
			if let newModel: T = try? JSONDecoder().decode(T.self, from: jsonPhotoObject) {
				// Populate to model structure
				completion(.success(newModel))
			} else {
				completion(.failure(.PopulateFail))
			}
			
		}).resume()
	}
}


