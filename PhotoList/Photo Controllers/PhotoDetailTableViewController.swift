//
//  PhotoDetailTableViewController.swift
//  PhotoList
//
//  Created by Woody Lee on 7/20/19.
//  Copyright © 2019 Woody Lee. All rights reserved.
//

import UIKit

class PhotoDetailTableViewController: UITableViewController {
	
	@IBOutlet weak var backDropImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	
	public var photoTitle: String?
	public var backDropImage: UIImage?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.title = "Photo Details"
		tableView.backgroundColor = .black
		titleLabel.textColor = .white
		
		backDropImageView.image = backDropImage
		titleLabel.text = photoTitle
    }
}
