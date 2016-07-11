//
//  TJWHomeFeedViewController.swift
//  TwitterJW
//
//  Created by Jacky Wang on 7/8/16.
//  Copyright © 2016 Jacky Wang. All rights reserved.
//

import UIKit

class TJWHomeFeedViewController: UITableViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var posts = [[String:AnyObject]]()
    private var isWaitingForRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.register(UINib(nibName: "TJWHomeFeedTableViewCell", bundle: Bundle.main) , forCellReuseIdentifier: "TJWHomeFeedTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh(self)
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        
        if isWaitingForRequest { return }
        isWaitingForRequest = true
        
        TJWAPI.sharedAPI.refreshTimeLine() { posts in
            self.isWaitingForRequest = false
            DispatchQueue.main.async() {

                if let posts = posts {
                    self.posts.insert(contentsOf: posts, at: 0)
                    self.tableView.reloadData()
                }
                if let refreshControl = sender as? UIRefreshControl {
                    refreshControl.endRefreshing()
                }
            }
        }
    }
    
     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
     func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TJWHomeFeedTableViewCell") as! TJWHomeFeedTableViewCell
        if posts.count > indexPath.row {
            let post = posts[indexPath.row]
            configureCellWithPost(cell: cell, post: post)
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > 0
            && (scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < 0)
            && self.posts.count > 0 {
            
            activityIndicator?.startAnimating()
            
            if isWaitingForRequest { return }
            isWaitingForRequest = true
            
            TJWAPI.sharedAPI.scrollTimeLine() { posts in
                self.isWaitingForRequest = false
                DispatchQueue.main.async() {
                    if let posts = posts {
                        self.posts.append(contentsOf: posts)
                        self.tableView.reloadData()
                    }
                    self.activityIndicator?.stopAnimating()
                }
            }
        }
    }
    
    private func configureCellWithPost(cell:TJWHomeFeedTableViewCell, post:[String:AnyObject]) {
        
        if let text = post["text"] as? String {
            cell.contentLabel.text = text
        }
        if let user = post["user"] as? [String:AnyObject] {
            if let profileImageUrl = user["profile_image_url_https"] as? String {
                
                TJWImageManager.sharedManager.requestImage(urlString: profileImageUrl) { data in
                    if let data = data {
                        cell.profileIcon.image = UIImage(data: data)
                    }
                }
            }
            if let name = user["name"] as? String {
                
                cell.userNameLabel.text = name
            }
            
            if let screenName = user["screen_name"] as? String {
                cell.screenNameLabel.text = " @"+screenName
            }
        }

        if let createdAt = post["created_at"] as? String {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            if let date = formatter.date(from: createdAt) {
                cell.timeStampLabel.text = Date().getTimeSinceString(date: date)
            }
        }
        if let retweetCount = post["retweet_count"] as? Int where retweetCount > 0 {
            
            cell.retweetCountLabel.text = "\(retweetCount)"
        } else {
            cell.retweetCountLabel.text = ""
        }
        if let favoriteCount = post["favorite_count"] as? Int where favoriteCount > 0 {
            
            cell.likeCountLabel.text = "\(favoriteCount)"
        } else {
            cell.likeCountLabel.text = ""
        }
    }
}
