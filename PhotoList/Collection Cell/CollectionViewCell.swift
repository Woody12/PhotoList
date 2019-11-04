//
//  CollectionViewCell.swift
//  PhotoList
//
//  Created by Woody Lee on 7/19/19.
//  Copyright © 2019 Woody Lee. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
	
	var photoImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		addSubview(photoImageView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		photoImageView.backgroundColor = .purple
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		NSLayoutConstraint.activate([
			photoImageView.topAnchor.constraint(equalTo: self.topAnchor),
			photoImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
			photoImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
			photoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}
}
