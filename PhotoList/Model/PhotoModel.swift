//
//  PhotoModel.swift
//  PhotoList
//
//  Created by Woody Lee on 7/19/19.
//  Copyright © 2019 Woody Lee. All rights reserved.
//

import Foundation
import UIKit

struct PhotoModel: Codable {
	
	enum CodingKeys: String, CodingKey {

		case id
		case owner
		case secret
		case server
		case farm
		case title
	}
	
	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(String.self, forKey: .id)
		owner = try values.decode(String.self, forKey: .owner)
		secret = try values.decode(String.self, forKey: .secret)
		server = try values.decode(String.self, forKey: .server)
		farm = try values.decode(Int.self, forKey: .farm)
		title = try values.decode(String.self, forKey: .title)
	}
	
	let id: String
	let owner: String
	let secret: String
	let server: String
	let farm: Int
	let title: String
	
	var posterImage: UIImage?
	var backdropImage: UIImage?
}
