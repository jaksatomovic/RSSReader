//
//  ViewController.swift
//  RSSReader
//
//  Created by Jakša Tomović on 02/02/2018.
//  Copyright © 2018 Jakša Tomović. All rights reserved.
//

import UIKit
import EVReflection
import Alamofire
import AlamofireXmlToObjects
import SafariServices


class FeedController: UIViewController {
    
    var _link: String?
    
    var items = [Item]()
    
    let cellId = "FeedCell"
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.darkBlue
        return cv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName:"FeedCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        view.addSubview(collectionView)
        collectionView.fillSuperview()
        
        fetchFrontPageData(url: _link!)
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        cell.item = items[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        
        let url:URL = URL(string: item.link!)!
        let safariViewController = SFSafariViewController(url: url) //SFSafariViewController(url: url, entersReaderIfAvailable: true)
        present(safariViewController, animated: true, completion: nil)
    }
    
}

extension FeedController {
    
    func fetchFrontPageData(url: String) {
        let URL = url
        print(url)
        Alamofire.request(URL)
            .responseObject { (response: DataResponse<FeedResponse>) in
                if let result = response.value {
                    guard let itemArray = result.channel?.item else {return}
                    for feed in itemArray {
                        self.items.append(feed)
                        print(feed)
                    }
                }
                self.collectionView.reloadData()
        }
    }    
}

