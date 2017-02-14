//
//  InstagramViewController.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/9/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit

public class InstagramViewController: BasicViewConroller {
  
  private static let instagramVC = InstagramViewController()
  public class func sharedInstance() -> InstagramViewController { return instagramVC }
  
  fileprivate let fmInstagram = FMInstagram.sharedInstance()
  public var datastore = DataStore.sharedInstance().instagram
  
  
  public let tableView = UITableView()
  fileprivate let refreshControl = UIRefreshControl()
  
  fileprivate var mediaRequestThrottler: Timer?
  fileprivate let placeholderLabel = UILabel()
  
  public let userProfileImageView = UIImageView()
  
  deinit {
    removeObserver(self, forKeyPath: #keyPath(datastore.accessToken))
    removeObserver(self, forKeyPath: #keyPath(datastore.medias))
    removeObserver(self, forKeyPath: #keyPath(datastore.username))
    removeObserver(self, forKeyPath: #keyPath(datastore.userProfileImageURL))
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    // setup UI
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Check Flickr", style: .plain, target: self, action: #selector(self.leftBarButtonTapped(button:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(self.rightBarButtonTapped(button:)))
    title = "Instagram"
    edgesForExtendedLayout = []
    
    // setup table view
    tableView.register(InstagramMediaCell.self, forCellReuseIdentifier: "InstagramMediaCell")
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorColor = .clear
    tableView.backgroundColor = .black
    tableView.allowsSelection = false
    view.addSubview(tableView)
    
    // setup refresh control
    refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
    refreshControl.tintColor = .white
    tableView.addSubview(refreshControl)
    
    // setup placeholder label
    placeholderLabel.text = "Looks like there's nothing on your feed right now! Tap \"Connect\" to connect."
    placeholderLabel.textAlignment = .center
    placeholderLabel.numberOfLines = 0
    placeholderLabel.textColor = .white
    tableView.addSubview(placeholderLabel)
    
    view.addSubview(userProfileImageView)

    // register observers
    addObserver(self, forKeyPath: #keyPath(datastore.accessToken), options: .new, context: nil)
    addObserver(self, forKeyPath: #keyPath(datastore.medias), options: .new, context: nil)
    addObserver(self, forKeyPath: #keyPath(datastore.username), options: .new, context: nil)
    addObserver(self, forKeyPath: #keyPath(datastore.userProfileImageURL), options: .new, context: nil)
  }
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    tableView.fillSuperview()
    placeholderLabel.anchorInCenter(width: screen.width - 32, height: 100)
    
    userProfileImageView.anchorInCorner(.topLeft, xPad: 16, yPad: 16, width: 48, height: 48)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    tableView.reloadData()
  }
}

// MARK: UIRefreshControl Delegate
extension InstagramViewController {
  public func pullToRefresh() {
    if !FMInstagram.sharedInstance().isAuthorized() { refreshControl.endRefreshing() }
    else { loadMedia(refreshData: true) }
  }
}

// MARK: UITableView Delegate
extension InstagramViewController: UITableViewDelegate, UITableViewDataSource {
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return screen.width
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return datastore.medias.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "InstagramMediaCell", for: indexPath) as? InstagramMediaCell {
      let imageURL = datastore.medias[indexPath.row].imageURL
      let caption = datastore.medias[indexPath.row].caption
      let videoURL = datastore.medias[indexPath.row].videoURL
      // download the image
      cell.imageURL = imageURL
      cell.caption = caption
      cell.videoURL = videoURL
      
      // async image download
      cell.mediaImageView.imageFromSource(imageURL, fitMode: .crop)
      
      return cell
    }
    return UITableViewCell()
  }
}

// MARK: UIScrollView Delegate
extension InstagramViewController {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // check if user has scroll to the bottom
    if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
      loadMedia()
    }
  }
}

// MARK: Instagram API
extension InstagramViewController {
  public func loadMedia(refreshData: Bool = false) {
    if !refreshData { showSpinnerIndicator() }
    // we throttle the request to make sure calls don't get called out so carelessly
    mediaRequestThrottler?.invalidate()
    mediaRequestThrottler = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
      // grab the last received media if it exists, skip if were refreshing data
      let id = refreshData ? "" : self?.datastore.medias.last?.id
      FMInstagram.sharedInstance().getUserMedia(afterMediaID: id) { results in
        if let data = results["data"] as? NSArray {
          log.debug("received \(data.count) objects")
          if refreshData { DataStore.sharedInstance().instagram.medias.removeAll(keepingCapacity: false) }
          let medias = data.map { InstagramMedia(data: $0 as? [String: AnyObject]) }
          DataStore.sharedInstance().instagram.medias.append(contentsOf: medias)
        }
      }
      FMInstagram.sharedInstance().getUserProfile() { results in
        if let username = results["data"]?["username"] as? String {
          DataStore.sharedInstance().instagram.username = username
        }
        if let profileImageURL = results["data"]?["profile_picture"] as? String {
          DataStore.sharedInstance().instagram.userProfileImageURL = profileImageURL
        }
      }
    }
  }
}

// MARK: User Interaction
extension InstagramViewController {
  
  public func leftBarButtonTapped(button: UIButton) {
    if let navigationController = navigationController {
      // loop through all the visible cells and tell the video player to stop playing
      tableView.visibleCells.map { $0 as? InstagramMediaCell }.forEach { $0?.avPlayer?.pause() }
      // being transiation
      UIView.transition(with: navigationController.view, duration: 1.0, options: [.transitionFlipFromLeft, .showHideTransitionViews], animations: { [weak self] in
        let flickrViewController = FlickrViewController.sharedInstance()
        self?.navigationController?.pushViewController(flickrViewController, animated: false)
      }, completion: { bool in
      })
    }
  }
  
  public func rightBarButtonTapped(button: UIButton) {
    fmInstagram.authenticate()
  }
}

// MARK: KVO
extension InstagramViewController {
  
  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    // reload the table view whenever the instagram datastore gets updated
    if let keyPath = keyPath {
      switch keyPath {
      case #keyPath(datastore.accessToken):
        loadMedia(refreshData: true)  
        break
      case #keyPath(datastore.medias):
        placeholderLabel.isHidden = datastore.medias.count > 0
        hideSpinnerIndicator()
        refreshControl.endRefreshing()
        tableView.reloadData()
        break
      case #keyPath(datastore.username):
        title = datastore.username
        break
      case #keyPath(datastore.userProfileImageURL):
        userProfileImageView.imageFromSource(datastore.userProfileImageURL, mask: .rounded)
        break
      default: break
      }
    }
  }
}
