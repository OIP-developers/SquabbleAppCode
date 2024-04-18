//
//  MyRewardsViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 12/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import MKToolTip


class MyRewardsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var rewards = [RewardsModel]()
    var offset = 0
    var isMoreData = true
    
    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        //getRewardList()
        AppFunctions.showSnackBar(str: "You have not received any rewards yet.")
        // Do any additional setup after loading the view.
    }
    
    //MARK:- UIButton Method
    @IBAction func backButtonAction(_  sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
}

extension MyRewardsViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRewardsTableViewCell", for: indexPath) as! MyRewardsTableViewCell
        //let obj = rewards[indexPath.row]
        //cell.cellSetup(obj: obj)
        //cell.claimButtonClicked = {
            //self.claimReward(obj: self.rewards[indexPath.row].challenge, index: indexPath.row)
        //}
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    @objc func imageTapped(_ gesture: UITapGestureRecognizer){
        let location = gesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: location)
        let obj = rewards[indexPath?.row ?? 0]
        let cell = tableView.cellForRow(at: IndexPath(row: indexPath?.row ?? 0, section: 0)) as! MyRewardsTableViewCell
        let preference = ToolTipPreferences()
        preference.drawing.bubble.color = .darkGray
        if obj.video_exist == 0{
            cell.contentView.showToolTip(identifier: "", message: "Video Not Available", arrowPosition: .bottom, preferences: preference, delegate: nil)
        }
        
    }
    
    
    //pagination
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("velocity = \(velocity)")
        if (scrollView.frame.size.height + scrollView.contentOffset.y) >= scrollView.contentSize.height{
            if isMoreData {
                offset = offset + 10
                getRewardList()
            }
        }
    }
}


extension MyRewardsViewController {
    func getRewardList(){
        var param = [String: Any]()
        param["limit"] = 10
        param["offset"] = offset
        
        WebServices.getMyRewards(params: param) { (response) in
            if let arr = response?.array {
                
                if self.offset == 0 {
                    self.rewards = arr
                }else {
                    if arr.count < 10 {
                        self.isMoreData = false
                    }
                    self.rewards.append(contentsOf: arr)
                }
                
                if self.rewards.count == 0 {
                    noDataFound(message: "No Data Found", tableView: self.tableView,tag: 101)
                    self.tableView.backgroundView?.isHidden = false
                }else {
                    if self.tableView.backgroundView?.tag == 101 {
                        self.tableView.backgroundView?.isHidden = true
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    func claimReward(obj: ChallengeModel, index: Int){
        var param = [String: Any]()
        param["challenge_id"] = obj.challenge_id
        param["claim_amount"] = obj.price
        
        WebServices.claimRewards(params: param) { (response) in
            if response?.statusCode == 200 {
                obj.claim_status = "2"
                self.tableView.reloadData()
            }
        }
    }
}

