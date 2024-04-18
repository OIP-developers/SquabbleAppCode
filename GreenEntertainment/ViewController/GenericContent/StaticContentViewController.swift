//
//  StaticContentViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 09/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class StaticContentViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var navLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!


    var agreeCompletion: ((Bool) -> Void)? = nil
    var screentype: ScreenType = .termsAndCondition
    var isFromSetting = false
    var obj = HomeModel()
    var modelObj = RewardsModel()

    var backCompletion: ((HomeModel) -> Void)? = nil
    var backFromPostCompletion: ((RewardsModel) -> Void)? = nil


    //MARK:- UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Helper Method
    func customSetup(){
     //   navLabel.text  = screentype.rawValue
        backButton.setImage(UIImage.init(named: isFromSetting ? "icn_back" : "icn_cross"), for: .normal)
        if isFromSetting {
            agreeButton.isHidden = true
            bottomConstraint.constant = 0
        }else {
            agreeButton.isHidden = false
            bottomConstraint.constant = 80
        }
      getStaticContent()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton){
        delay(delay: 0.5) {
            self.backCompletion?(self.obj)
            self.backFromPostCompletion?(self.modelObj)
        }
        agreeCompletion?(false)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func agreeButtonAction(_ sender: UIButton){
        agreeCompletion?(true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension StaticContentViewController {
    func getStaticContent(){
        
        let content = """
Squabble(™) Challenge Terms and Conditions\n
These Squabble(™) Challenge Terms and Conditions (“Squabble(™) Terms”) are in addition to and should be read together with the specific entry instructions applying to the specific challenge (“Challenge Information”). In the event of a conflict between the terms of the Squabble(™) Terms and the Challenge Information, the Squabble(™) Terms shall prevail.
* Apple is not a sponsor of the Challenges and not affiliated with Squabble(™). Prizes granted on Squabble(™) are in no way sponsored by or affiliated with Apple, Google or any other app store provider.
Payments from Squabble(™) to Users will be processed as Stripe transfers.
All entrants must comply with the entry requirements set out in the Challenge Information, these Squabble(™) Terms and Squabble(™)'s Community Guidelines. Any failure to comply with the Challenge Information and/or these Squabble(™) Terms may result in disqualification from the Challenge.
By entering a Challenge each entrant acknowledges that they have read, understood and agrees to be bound by the Challenge Information and these Squabble(™) Terms. If an entrant is under 18 years old, such entrant agrees that they and their parent / guardian have read, understood and agreed to be bound by the Challenge Information and these Squabble(™) Terms on behalf of the entrant.
Squabble(™) reserves the right to amend and update these Squabble(™) Terms at its sole discretion from time to time and such changes will become effective as soon as they are published on the Squabble(™) website available at www.squabblewin.com (the “Squabble(™) Website”) and the Squabble(™) mobile app (“App”).

Unless otherwise stated in the Challenge Information these Squabble(™) Terms apply to all Challenges aimed at those aged 18 or older.

1. The Promoter. The promoter of all Challenges is: Green Entertainment LLC (a company registered in the United States of America) with registered address at 7740 Jamestown S Drive, Fishers, IN, 46038 (“Squabble(™)”) and/or any group companies wholly or partially owned by Squabble(™).
2. The Challenge. The title and description of each Challenge will be provided in the applicable Challenge Information for each Challenge. Some Challenges will be a comprehensive challenge of all talents and content submissions that are allowed by the rules explained in our Privacy Statement.
3. How to Enter. Challenges may be entered on our Challenge home page via the “Participate” button, or directly through your personal profile by initiating the “Add to a Challenge” icon on a qualified video. All Challenge entries must be submitted by the closing time (“Closing Time”) which will be displayed on the app as a countdown timer. When the timer and Participate button are no longer visible, the Challenge entries will not be accepted. Winners will be notified within 5 days of the Closing Time (or such other date specified in the Challenge Information). Challenge entries received after the Closing Time will not be considered.

No purchase necessary (unless otherwise stated in the Challenge Information or Squabble(™) App) and there is no charge to register for use of the Squabble(™) Website or Squabble(™) App. However standard charges of entry (including standard telephone/SMS/text message network rates) may be incurred and all entrants must ask permission from the bill payer before entering.

Squabble(™) will not accept: (a) responsibility for Challenge entries that are lost, damaged or delayed, regardless of cause, including, for example, as a result of any equipment failure, technical malfunction, systems, satellite, network, server, computer hardware or software failure of any kind; or (b) proof of transmission as proof of receipt of entry to the Challenge.

For help with entries, please contact Squabble(™) at admin@squabblewin.com.

Please see the Squabble(™) Website for a copy of the applicable Challenge Information and these Squabble(™) Terms.

Challenge winners will be determined by public voting by registered and non-registered users of the Squabble(™) App.

4. Eligibility. Unless otherwise stated in the applicable Challenge Information, Challenges are open to all individuals aged 13 years or over. Further restrictions for certain Challenges regarding age and residence may be specified in the Challenge Information and shall take precedence over these Squabble(™) Terms.

In entering the Challenge, each entrant confirms they are eligible to do so and eligible to claim the prize or any prize they may win. Entrants under the age of 18 years old must have the consent of a parent or guardian over 18 to enter the Challenge. Squabble(™) may require you to provide proof that you are eligible to enter the Challenge and, if applicable, it reserves the right to obtain proof of such parental or guardian consent, and to choose another winner if such proof, where requested, has not been provided.

Squabble(™) has the right at any time to require entrants to provide proof of identity as evidence of eligibility to participate. If an entrant fails to comply with a request for proof of identity, or provides false or misleading information, Squabble(™) may at its discretion, disqualify the entrant from the Challenge, or, where appropriate allocate the prize to another eligible entrant. Such a decision will be final and no correspondence will be entered into about a decision regarding eligibility.

5. Entry. Unless otherwise stated, entrants may make one entry per Challenge as permitted under the applicable Challenge Information. Entries must be submitted in accordance with the format specified in the Challenge Information.

Squabble(™) is not liable for any associated cost to entrants or their parents and/or guardians of entering a Challenge unless expressly specified in the Challenge Information.

All Challenge entries and any accompanying material submitted to Squabble(™) will become the property of Squabble(™) on receipt and will not be returned. Entrants (including the winner) hereby assign all intellectual property rights (if any) and waive all moral rights in their entry to Squabble(™). Squabble(™) is unable to return any entries submitted unless expressly agreed otherwise.

Squabble(™) accepts no responsibility for entries that are delayed or which are not received for any reason and also has no liability in respect of any incomplete entries that are received. Incomplete entries will not be counted and will be discarded. Squabble(™) has no responsibility to inform any entrant that their entry is incomplete and not valid for entry to the Challenge.

Entrants warrant that all information they submit is correct and not obscene or offensive or otherwise in breach of any third party rights or Squabble(™)'s Community Guidelines. Squabble(™) reserves the right to disqualify any entrant from the Challenge if it believes or suspects (in its sole discretion) that such entrant has cheated or breached any of these Squabble(™) Terms, Community Guidelines or the applicable Challenge Information.

6. The Prize. The prizes offered in Challenges may be cash prizes or prizes provided by a sponsor (or alternative promoter) rather than Squabble(™) and in such circumstances Squabble(™) does not accept any responsibility for the accuracy of any prize descriptions supplied by such third parties. A third party providing the prize in a Challenge may impose terms and conditions upon the use or the acceptance of the prize. The winner shall be advised of these terms and conditions prior to their acceptance of the prize.

Non-cash prizes are subject to availability and no cash alternative is available. Squabble(™) reserves the right to offer an alternative non-cash prize of equal or greater value than that advertised. Prizes are not transferable and non-negotiable.

Prizes awarded to users through the random selection process of submitted votes (“Random Voter Prizes”) are subject to availability and no cash alternative is available. Squabble(™) reserves the right to offer an alternative non-cash prize of equal or greater value than that advertised. Prizes are not transferable and non-negotiable.

Squabble(™) accepts no responsibility for any costs or expenses incurred by the winner, their guests, or parents/guardians in connection with claiming any prize won in the Challenge (including travel to and from any event). The parents/guardians of the prize winners are responsible for paying all taxes, duties and any other levies on prize winnings if applicable.

7. Winners. The decision is final and no correspondence or discussion will be entered into. Squabble(™) will contact the winner as soon as practicable after the date Squabble(™) announces the winner (“Reveal Date”), via any one of the following methods: push notification, direct message, or using the email address provided by the user during the registration process or in their profile section.

Squabble(™) will either publish or make available information that indicates that a valid awareness took place. To comply with this obligation Squabble(™) will publish the username and country of major prize winners and, if applicable, their winning entries on the Squabble(™) Website and/or Squabble(™) Showcase page on the Squabble(™) App on or after the Reveal Date.

If you object to any or all of your username, county and winning entry being published or made available, please contact Squabble(™) at admin@squabblewin.com. In such circumstances, Squabble(™) must still provide the information and winning entry to the Advertising Standards Authority on request.

Squabble(™) will make all reasonable efforts to contact the winner. If the winner cannot be contacted or is not available, or has not claimed their prize within 10 days of the Announcement Date, Squabble(™) reserves the right to offer the prize to the next eligible entrant selected from the entries that were received before the Closing Date. Squabble(™) does not accept any responsibility if you are not able to take up the prize.

8. General. Insofar as is permitted by law, Squabble(™) or its agents will not in any circumstances be responsible or liable to compensate the winner (and/or any guest or parent/guardian as applicable) or accept any liability for any loss, damage, personal injury or death occurring as a result of taking up the prize or in connection with the Challenge except where it is caused by the negligence of Squabble(™) or its agents or that of their employees.

To the fullest extent permitted by law Squabble(™) does not make any express or implied warranties, representations or endorsements whatsoever with regard to the Challenge, prizes or any information, service or product provided in connection with a Challenge.

Entrants (including the winner) shall not do anything that could damage or harm the reputation of Squabble(™), or any products included as part of the Challenge prize. If there is any reason to believe that there has been a breach of these Squabble(™) Terms or the Challenge Information, Squabble(™) may, at its sole discretion, reserve the right to exclude an entrant from participating in the Challenge.

Squabble(™) reserves the right to hold void, suspend, cancel, or amend the Challenge where it becomes necessary to do so.

The entry into the Challenge may not be lawful in all jurisdictions. Each entrant is responsible for determining whether their entry into and participation in the Challenge complies with applicable law.

These Squabble(™) Terms and the Challenge shall be governed by United States law, and the parties submit to the non-exclusive jurisdiction of the courts of Indiana.

9. Use of Data Entrants and their parents/guardians agree that (if they win) Squabble(™) may publicise their entry, including photos, images or videos submitted as part of their entry, names, likeness and statements in connection with/resulting from the Challenge in any and all media and social media. Unless stated otherwise in the Challenge Information, no entrants, winners, their guests or parents/guardians shall be obliged to take part in any photo publicity and parent/guardian consent shall be obtained by Squabble(™) prior to undertaking any photo publicity.

Entrants shall not enter into any correspondence or give interviews with any third party on any matters arising from the Challenge, without the prior written permission of Squabble(™).

Squabble(™) and/or third party promoters for the Challenge may use data supplied by entrants to process the Challenge, inform winning participants of their winning entry, distribute prizes and, where the relevant marketing permissions have been collected, to contact entrants in relation to other Challenges it runs or to market products or services it believes may be of interest to them.

Entry into the Challenge shall constitute consent to the uses of data contained in these Squabble(™) Terms. If, at any time, entrants no longer wish to be contacted by Squabble(™), they should contact Squabble(™) in accordance with its Privacy Statement available on website (www.Squabble(™)app.net) and the App, which set out the basis on which Squabble(™) will collect and process any personal data from entrants or that entrants provide to Squabble(™). Squabble(™) will use and keep personal data in accordance with its Privacy Statement. Please read the Privacy Policy carefully and if entrants or their parents/guardians have any questions, or would like to request a paper copy of the Privacy Statement, contact Squabble(™) at admin@squabblewin.com
"""

        textView.text = content
        textView.textColor = .white
        
        /*var param = [String: Any]()
        param["slug"] = screentype  == .termsAndCondition ? "term" : "about"
        WebServices.getStaticContent(params: param) { (response) in
            if  let  obj = response?.object {
                self.textView.attributedText = obj.content?.html2AttributedString
                self.textView.textColor = .white
                self.navLabel.text = obj.page_title
            }
        }*/
    }
}
