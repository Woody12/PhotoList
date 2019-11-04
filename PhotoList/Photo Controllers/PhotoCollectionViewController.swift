//
//  PhotoCollectionViewController.swift
//  PhotoList
//
//  Created by Woody Lee on 7/19/19.
//  Copyright © 2019 Woody Lee. All rights reserved.
//

import UIKit

protocol PhotoCollectionViewProtocol {
	func displayPhotos()
	func displayPhotos(at: IndexPath)
	func displayError(message: String?)
}

class PhotoCollectionViewController: UIViewController {
	
	private weak var collectionView: UICollectionView!
	private let searchConroller = UISearchController(searchResultsController: nil)
	
	private var collectionCell: CollectionViewCell?
	private var photoCollectionPresenter: PhotoCollectionViewPresenter?
	
	private var currentSelectedRow = -1
	private let CollectionCellID = "CollectionCell"
	private let PhotoDetailID = "PhotoSegue"
	
	private let itemsPerRow: CGFloat = 2
	private let sectionInsets = UIEdgeInsets(top: 100.0,
											 left: 20.0,
											 bottom: 50.0,
											 right: 20.0)
	
	private let maxStringLength = 3
	private var filterText = ""
	
	override func loadView() {
		super.loadView()

		// Create Collection View and add Autolayout Constraint
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

		collectionView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(collectionView)
		
		NSLayoutConstraint.activate([

			collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60.0),
			collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
			collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
			collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
			
		])
		
		self.collectionView = collectionView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Photos"
		self.navigationController?.navigationBar.barTintColor = .black
		
		initCollectionView()
		initSearchBar()
	
		// Assign Presenter to handle Business Layer
		self.photoCollectionPresenter = PhotoCollectionViewPresenter(self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == PhotoDetailID {
			let photoDetailTableVC = segue.destination as! PhotoDetailTableViewController
			
			if currentSelectedRow != -1 {
				photoDetailTableVC.photoTitle = self.photoCollectionPresenter?.showPhotoTitle(index: currentSelectedRow)
				photoDetailTableVC.backDropImage = self.photoCollectionPresenter?.showPhotoBackdrop(index: currentSelectedRow)
			}
		}
	}
	
	// MARK: Private Methods
	
	private func initCollectionView() {
		// Set Delegate, Datasource
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.backgroundColor = .black
		
		self.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionCellID)
	}
	
	private func initSearchBar() {
		searchConroller.searchResultsUpdater = self
		searchConroller.delegate = self
		searchConroller.searchBar.delegate = self
		searchConroller.hidesNavigationBarDuringPresentation = false
		searchConroller.dimsBackgroundDuringPresentation = true
		searchConroller.obscuresBackgroundDuringPresentation = true
		searchConroller.searchBar.placeholder = "Search Photo"
		searchConroller.searchBar.tintColor = .gray
		
		searchConroller.searchBar.sizeToFit()
		searchConroller.searchBar.becomeFirstResponder()
		
		// Change font and text color
		let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.gray]
		UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes
		
		self.navigationItem.searchController = searchConroller
		self.definesPresentationContext = true
	}
}

extension PhotoCollectionViewController: PhotoCollectionViewProtocol {
	
	public func displayPhotos() {
		self.collectionView.reloadData()
	}
	
	public func displayPhotos(at indexPath: IndexPath) {
		self.collectionView.reloadItems(at: [indexPath])
	}
	
	public func displayError(message: String?) {
		
		let alertController = UIAlertController(title: "Something went wrong!", message: message, preferredStyle: .alert)
		let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		
		alertController.addAction(alertAction)
		present(alertController, animated: true, completion: nil)
	}
}

extension PhotoCollectionViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
	
		collectionView.deselectItem(at: indexPath, animated: true)
		
		// Show Detail
		currentSelectedRow = indexPath.row
		performSegue(withIdentifier: PhotoDetailID, sender: self)
	}
}

extension PhotoCollectionViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		return photoCollectionPresenter?.numberOfPhotos() ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCellID, for: indexPath) as! CollectionViewCell
		
		if let image = photoCollectionPresenter?.showPhotoPoster(indexPath: indexPath) {
			collectionViewCell.photoImageView.image = image
		} else {
			// Show default purple color
			collectionViewCell.contentView.backgroundColor = .purple
		}
		
		return collectionViewCell
	}
}

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
	
		let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
		let availableWidth = view.frame.width - paddingSpace
		let widthPerItem = availableWidth / itemsPerRow
		
		return CGSize(width: widthPerItem, height: widthPerItem)
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		return sectionInsets
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return sectionInsets.left
	}
}

extension PhotoCollectionViewController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		searchController.searchBar.text = filterText
	}
}

extension PhotoCollectionViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		
		// Check if filter is cleared
		if let searchText = searchController.searchBar.text,
			searchText.trimmingCharacters(in: .whitespaces).count == 0,
			filterText.count > 0 {
			
			// Display all photos
			filterText = ""
			filterSearch()
			
			self.searchConroller.dismiss(animated: true, completion: nil)
		}
	}
}

extension PhotoCollectionViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		// Perform filter search
		if let searchText = searchBar.text {
			filterText = searchText
			filterSearch(query: searchText)
		}
		
		self.searchConroller.dismiss(animated: true, completion: nil)
	}
	
	private func filterSearch(query: String = "") {
		// Start searching if length > maxStringLength
		if query.count >= maxStringLength {
			self.photoCollectionPresenter?.retrieveLatestPhotos(query)
		}else if (query.count == 0) {
			// Reset
			self.photoCollectionPresenter?.retrieveLatestPhotos()
		}
	}
}
