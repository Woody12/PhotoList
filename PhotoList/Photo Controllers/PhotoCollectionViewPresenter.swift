//
//  PhotoCollectionViewPresenter.swift
//  PhotoList
//
//  Created by Woody Lee on 7/19/19.
//  Copyright © 2019 Woody Lee. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewPresenter {
	
	public var photoCollectionVC: PhotoCollectionViewProtocol?
	
	private let dataReadFailMsg = "Error loading data."
	private let populateFailMsg = "Error populating data perhaps due to network issue."
	
	private let imageURLPart1 = "https://farm"
	private let imageURLPart2 = ".staticflickr.com/"
	
	private let filterPhotoURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&text="
	
	private let apiParam = "&api_key="
	
	private var photoModels: [PhotoModel]?
	
	init(_ photoVC: PhotoCollectionViewProtocol?) {
		photoCollectionVC = photoVC
		
		// Load data to model
		retrieveLatestPhotos()
	}
	
	public func numberOfPhotos() -> Int {
		return photoModels?.count ?? 0
	}
	
	public func showPhotoPoster(indexPath: IndexPath) -> UIImage? {
		
		// Show image if already downloaded else invoke asynch call
		if let posterImage = photoModels?[indexPath.row].posterImage {
			return posterImage
		}else {
				
			// Invoke Asynchronous Call
			if let photoModel = photoModels?[indexPath.row] {
					
				let farm = String(photoModel.farm)
				let serverId = photoModel.server + "/"
				let id = photoModel.id
				let secret = photoModel.secret

				var photoPath = imageURLPart1 + farm + imageURLPart2 + serverId + id
				photoPath = photoPath + "_" + secret
					
				let smallImagePath = photoPath + "_q.jpg"
				
				DispatchQueue.global().async { [weak self] in
					if let data = try? Data(contentsOf: URL(string: smallImagePath)!) {
						if let image = UIImage(data: data),
							self?.photoModels?.count ?? 0 > indexPath.row {

							DispatchQueue.main.async {
								self?.photoModels?[indexPath.row].posterImage = image
								self?.photoCollectionVC?.displayPhotos(at: indexPath)
							}
						}
					}
				}
				
				let largeImagePath = photoPath + "_b.jpg"
				
				// Retrieve larger image for detail
				DispatchQueue.global().async { [weak self] in
					if let data = try? Data(contentsOf: URL(string: largeImagePath)!) {
						if let image = UIImage(data: data),
							self?.photoModels?.count ?? 0 > indexPath.row {

							DispatchQueue.main.async {
								self?.photoModels?[indexPath.row].backdropImage = image
							}
						}
					}
				}
			}

			return nil
		}
	}
	
	public func showPhotoTitle(index: Int) -> String? {
		return photoModels?[index].title
	}
	
	public func showPhotoBackdrop(index: Int) -> UIImage? {
		return photoModels?[index].backdropImage
	}
}

extension PhotoCollectionViewPresenter {
	
	public func retrieveLatestPhotos(_ query: String = "Animal") {
		
		let queryEncoded = query.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
		let showPhotoURL = filterPhotoURL + queryEncoded + apiParam
		let resource: Resource<[PhotoModel]> = Resource(urlString: showPhotoURL + apiParam, method: "GET")
		
		WebService().loadPhoto(resource: resource) { [weak self] (result: Result<[PhotoModel], NetworkError>) in
			
			switch result {
			case .failure(let reason):
				
				let errorMsg = ((reason == .DataReadFail) ? self?.dataReadFailMsg : self?.populateFailMsg)
				
				DispatchQueue.main.async {
					self?.photoCollectionVC?.displayError(message: errorMsg)
				}
				
			case .success(let photoData):
				
				// Create persistent storage
				self?.photoModels = photoData
				
				DispatchQueue.main.async {
					
					// Invoke display photos
					self?.photoCollectionVC?.displayPhotos()
				}
			}
		}
	}
}
