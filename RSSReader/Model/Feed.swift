//
//  Feed.swift
//  RSSReader
//
//  Created by Jakša Tomović on 02/02/2018.
//  Copyright © 2018 Jakša Tomović. All rights reserved.
//

import UIKit
import EVReflection
import Alamofire
import AlamofireXmlToObjects



class FeedResponse: EVObject {
    var channel: Channel?
}

class Channel: EVObject {
    var item: [Item] = [Item]()
    var title: String?
    var image: FeedImage?
}

class FeedImage: EVObject {
    var url: String?
}

class Item: EVObject {
    var title: String?
    var link: String?
    var image: FeedImage?  

}

//class Service {
//    func fetchFrontPageData() {
//        let URL = "https://hnrss.org/frontpage"
//        Alamofire.request(URL)
//            .responseObject { (response: DataResponse<FeedResponse>) in
//                if let result = response.value {
//                    print(result)
//                }
//        }
//    }
//}

