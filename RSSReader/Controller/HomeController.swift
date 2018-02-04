//
//  HomeController.swift
//  RSSReader
//
//  Created by Jakša Tomović on 02/02/2018.
//  Copyright © 2018 Jakša Tomović. All rights reserved.
//

import UIKit
import EVReflection
import Alamofire
import AlamofireXmlToObjects
import CoreData
import UserNotifications

var numberOfStories = [Int]()
var numberOfNewStories = [Int]()

class HomeController: UITableViewController {
    
    var feedList = [Channel]()
    
    var coreDataModels = [FeedModel]()

    let timedNotificationIdentifier = "timedNotificationIdentifier"

    
    private func fetchFeedList() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<FeedModel>(entityName: "FeedModel")
        
        do {
            let feeds = try context.fetch(fetchRequest)
            
            feeds.forEach({ (feed) in
                fetchFeed(url: feed.link ?? "")
                print(feed.link ?? "")
            })
            
            self.coreDataModels = feeds
            self.tableView.reloadData()
            
        } catch let fetchErr {
            print("Failed to fetch feed:", fetchErr)
        }
    }
    
    let cellId = "cellId"
    
    func showAlert() {
        let alert = UIAlertController(title: "Simulation", message: "Press home button, put app in background and in about 30 seconds you will receive local notification", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFeedList()
        
        view.backgroundColor = .white
        
        navigationItem.title = "Feed List"
        
        tableView.backgroundColor = UIColor.darkBlue
        tableView.separatorColor = .white
        tableView.tableFooterView = UIView()
        
        tableView.register(ListCell.self, forCellReuseIdentifier: cellId)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddFeed))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(sendNotification))

    }
    
    @objc func sendNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.showAlert()
                self.scheduleNotification()
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (succ, err) in
                    if let err = err {
                        print(err)
                    } else {
                        self.showAlert()
                        self.scheduleNotification()
                    }
                })
            }
        }
    }
    
    
    
    
    @objc func handleAddFeed() {
        var inputTextField: UITextField?
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Add New Feed Source (link)", message: "", preferredStyle: .alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
            print("Trying to save feed...")
            guard let text = inputTextField?.text else {return}
            let context = CoreDataManager.shared.persistentContainer.viewContext
            let feed = NSEntityDescription.insertNewObject(forEntityName: "FeedModel", into: context)
            
            feed.setValue(text, forKey: "link")
            
            // perform the save
            do {
                try context.save()
                // success
                self.coreDataModels.append(feed as! FeedModel)
                self.fetchFeed(url: text)
            } catch let saveErr {
                print("Failed to save feed:", saveErr)
            }
        }
        actionSheetController.addAction(nextAction)
        actionSheetController.addTextField { textField -> Void in
            inputTextField = textField
        }
        
        self.present(actionSheetController, animated: true, completion: nil)
    
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.text = "Titles"
        view.addSubview(label)
        label.fillSuperview()
        view.backgroundColor = .lightBlue
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListCell
        
        cell.backgroundColor = .tealColor
        let item = feedList[indexPath.row]
        cell.item = item
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedList.count
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let feed = self.feedList[indexPath.row]
            print("Attempting to delete feed:", feed.title ?? "")
   
            self.feedList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // delete the company from Core Data
            let context = CoreDataManager.shared.persistentContainer.viewContext
            
            context.delete(self.coreDataModels[indexPath.row])
            
            do {
                try context.save()
            } catch let saveErr {
                print("Failed to delete feed:", saveErr)
            }
            
        }
        deleteAction.backgroundColor = UIColor.lightRed

        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = FeedController()
        vc._link = coreDataModels[indexPath.row].link
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeController {
    func fetchFeed(url: String) {
        let URL = url
        Alamofire.request(URL)
            .responseObject { (response: DataResponse<FeedResponse>) in
                if let result = response.value {
                    guard let channel = result.channel else {return}
                    self.addNewFeedSource(feed: channel)
                    let count = result.channel?.item.count
                    print(count as Any)
                    numberOfStories.append(count!)
                }
                self.tableView.reloadData()
        }
    }
    
    func checkForNewStroies() {
        print("checking for new stories...")
        var urls = [String]()
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<FeedModel>(entityName: "FeedModel")
        
        do {
            let feeds = try context.fetch(fetchRequest)
            feeds.forEach({ (feed) in
                urls.append(feed.link ?? "")
            })
        } catch let fetchErr {
            print("Failed to fetch feed:", fetchErr)
        }
        for url in urls {
            var index = 0
            for i in 0..<urls.count {
                if urls[i] == url {
                    index = i
                }
            }
            Alamofire.request(url)
                .responseObject { (response: DataResponse<FeedResponse>) in
                    if let result = response.value {
                        guard let items = result.channel?.item else {return}
                        numberOfNewStories.append(items.count)
                    }
                    
                    if numberOfNewStories.last! > numberOfStories[index] {
                        self.scheduleNotification()
                    }
            }
        }
    }
    
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hi"
        content.body = "You have new rss stories"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30.0, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: timedNotificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print(error)
            } else {
                print("notification scheduled")
            }
        }
    }
    
    func addNewFeedSource(feed: Channel) {
        feedList.append(feed)
        let newIndexPath = IndexPath(row: feedList.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}




















