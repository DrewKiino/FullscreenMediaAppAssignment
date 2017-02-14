//
//  FlickrViewController.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/9/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit
import Neon

public class FlickrViewController: BasicViewConroller {
  
  private static let flickrVC = FlickrViewController()
  public class func sharedInstance() -> FlickrViewController { return flickrVC }
  
  fileprivate let fmFlickr = FMFlickr.sharedInstance()
  
  fileprivate var collectionView: UICollectionView!
  fileprivate let placeholderLabel = UILabel()
  fileprivate var mediaRequestThrottler: Timer?
  fileprivate var mediaLabelThrottler: Timer!
  
  fileprivate let refreshControl = UIRefreshControl()
  
  public let mediaLabel = UILabel()
  
  private let gradientContainer = UIView()
  private let topGradient: CAGradientLayer = CAGradientLayer()
  private let bottomGradient: CAGradientLayer = CAGradientLayer()
  
  public var datastore = DataStore.sharedInstance().flickr
  
  deinit {
    removeObserver(self, forKeyPath: #keyPath(datastore.oauthToken))
    removeObserver(self, forKeyPath: #keyPath(datastore.medias))
    removeObserver(self, forKeyPath: #keyPath(datastore.username))
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    // setup UI
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Check Instagram", style: .plain, target: self, action: #selector(self.leftBarButtonTapped(button:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(self.rightBarButtonTapped(button:)))
    title = "Flickr"
    
    // setup collection view
    let collectionViewLayout = UICollectionViewFlowLayout()
    collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    collectionViewLayout.minimumInteritemSpacing = 1.0
    collectionViewLayout.minimumLineSpacing = 1.0
    collectionViewLayout.itemSize = CGSize(width: floor(screen.width / 3) - 1, height: floor(screen.width / 3) - 1)
    collectionView = UICollectionView(frame: .null, collectionViewLayout: collectionViewLayout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(FlickrMediaCollectionViewCell.self, forCellWithReuseIdentifier: "FlickrMediaCollectionViewCell")
    view.addSubview(collectionView)
    
    // setup refresh control
    refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
    refreshControl.tintColor = .white
    collectionView.addSubview(refreshControl)
    
    // setup placeholder label
    placeholderLabel.text = "Looks like there's nothing on your feed right now! Tap \"Connect\" to connect."
    placeholderLabel.textAlignment = .center
    placeholderLabel.numberOfLines = 0
    placeholderLabel.textColor = .white
    collectionView.addSubview(placeholderLabel)
    
    // setup gradients
    gradientContainer.isUserInteractionEnabled = false
    view.addSubview(gradientContainer)
    topGradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
    topGradient.locations = [0.0, 1.0]
    topGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
    topGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
    gradientContainer.layer.insertSublayer(topGradient, at: 0)
    bottomGradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
    bottomGradient.locations = [0.0, 1.0]
    bottomGradient.startPoint = CGPoint(x: 0.5, y: 1.0)
    bottomGradient.endPoint = CGPoint(x: 0.5, y: 0.0)
    gradientContainer.layer.insertSublayer(bottomGradient, at: 0)
    
    // setup media label
    mediaLabel.backgroundColor = .clear
    mediaLabel.numberOfLines = 0
    mediaLabel.textColor = .white
    view.addSubview(mediaLabel)
    
    // register observers
    addObserver(self, forKeyPath: #keyPath(datastore.oauthToken), options: .new, context: nil)
    addObserver(self, forKeyPath: #keyPath(datastore.medias), options: .new, context: nil)
    addObserver(self, forKeyPath: #keyPath(datastore.username), options: .new, context: nil)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    collectionView.fillSuperview()
    placeholderLabel.anchorInCenter(width: screen.width - 32, height: 100)
    
    // media label
    mediaLabel.anchorAndFillEdge(.bottom, xPad: 16, yPad: 8, otherSize: AutoHeight)
    
    // gradient
    gradientContainer.fillSuperview()
    topGradient.anchorToEdge(.top, padding: 0, width: view.frame.width, height: 50)
    bottomGradient.anchorToEdge(.bottom, padding: 0, width: view.frame.width, height: max(100, mediaLabel.height))
  }
}

// MARK: VC Methods
extension FlickrViewController {
  public func loadMedia(refreshData: Bool = false) {
    if !refreshData { showSpinnerIndicator() }
    mediaRequestThrottler?.invalidate()
    mediaRequestThrottler = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
      self?.fmFlickr.getInterestingPhotos(resetPage: refreshData) { photos in
        if refreshData { DataStore.sharedInstance().flickr.medias.removeAll(keepingCapacity: false) }
        let medias = photos.map { FlickrMedia(data: $0) }
        DataStore.sharedInstance().flickr.medias.append(contentsOf: medias)
      }
    }
  }
}

// MARK: UIRefreshControl Delegate
extension FlickrViewController {
  public func pullToRefresh() {
    if !fmFlickr.isAuthorized() { refreshControl.endRefreshing() }
    else { loadMedia(refreshData: true) }
  }
}

// MARK: Collection View Delegates
extension FlickrViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return datastore.medias.count
  }
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrMediaCollectionViewCell", for: indexPath) as? FlickrMediaCollectionViewCell {
      
      let imageURL = datastore.medias[indexPath.row].imageURL
      
      cell.imageURL = imageURL
      
      // async image download
      cell.mediaImageView.imageFromSource(imageURL, fitMode: .crop)
      
      return cell
    }
    return UICollectionViewCell()
  }
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let title = datastore.medias[indexPath.row].title
    mediaLabel.text = title
    viewWillLayoutSubviews()
    mediaLabelThrottler?.invalidate()
    mediaLabelThrottler = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] timer in
      self?.mediaLabel.text = nil
    }
  }
}

// MARK: UIScrollView Delegate
extension FlickrViewController {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // check if user has scroll to the bottom
    if collectionView.contentOffset.y >= (collectionView.contentSize.height - collectionView.frame.size.height) {
      loadMedia()
    }
  }
}

// MARK: User Interaction
extension FlickrViewController {
  
  public func leftBarButtonTapped(button: UIButton) {
    if let navigationController = navigationController {
      UIView.transition(with: navigationController.view, duration: 1.0, options: [.transitionFlipFromLeft, .showHideTransitionViews], animations: { [weak self] in
        if let _ = self?.navigationController?.popToRootViewController(animated: false) {}
      }, completion: { bool in
      })
    }
  }
  
  public func rightBarButtonTapped(button: UIButton) {
      FMFlickr.sharedInstance().authenticate()
  }
}

// MARK: KVO
extension FlickrViewController {
  
  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    // reload the table view whenever the instagram datastore gets updated
    if let keyPath = keyPath {
      switch keyPath {
      case #keyPath(datastore.oauthToken):
        loadMedia(refreshData: true)
        break
      case #keyPath(datastore.medias):
        placeholderLabel.isHidden = datastore.medias.count > 0
        hideSpinnerIndicator()
        refreshControl.endRefreshing()
        collectionView.reloadData()
        break
      case #keyPath(datastore.username):
        title = datastore.username
        break
      default: break
      }
    }
  }
}
