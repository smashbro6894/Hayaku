//
//  RunViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/21/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit
import Kanna
import Kingfisher
import SafariServices
import Alamofire

class RunViewController: UIViewController, SFSafariViewControllerDelegate {
    
    private var twitchClientId = "tkcu7nhde15jr0qpw6yoy2lp57xkuz"
    
    
    var players : [Player]?
    var player : Player?
    var run : Run?
    var backgroundURL : String?
    var category : String?
    var subcategories : String?
    var gameName : String?
    var user : ResultsUsers?
    var place : String?
    


    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var runnerNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var subcategoriesLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var gameNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        
        navigationController?.navigationBar.prefersLargeTitles = false
        super.viewDidLoad()
        gameNameLabel.text = gameName
        if player?.rel == "guest" {
            runnerNameLabel.text = player?.name
        } else {
            runnerNameLabel.text = player?.names?.international
        }
        if user != nil {
            runnerNameLabel.text = user?.names.international
        }
//        if let url = URL(string: backgroundURL ?? "") {
//            guard let data = try? Data(contentsOf: url) else { return }
//            view.backgroundColor = UIColor(patternImage: UIImage(data: data)!)
//        }
        
        thumbnailImageView.image = UIImage(named: "Close Button")
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .black, scale: .small)
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        playButton.imageView?.contentMode = .scaleAspectFill
        playButton.addTarget(self, action: #selector(imageViewTapped), for: .touchUpInside)
        if let subcategoriesText = subcategories {
            subcategoriesLabel.text = subcategoriesText
        } else {
            subcategoriesLabel.text = ""
        }
        if let categoryText = category {
            categoryLabel.text = categoryText
        }
        timeLabel.text = String(describing: run!.times.primary).replacingOccurrences(of: "PT", with: "").lowercased()
    
        placeLabel.text = "\(place!) place"
        
        

        if let videoLink = run?.videos?.links![0].uri {
            print(videoLink)
            if videoLink.contains("twitch") {
                let twitchLinkArray = videoLink.split(separator: "/")
                print(twitchLinkArray)
                let headers : HTTPHeaders = ["Client-ID" : twitchClientId]
                var videoId: String?
                videoId = String(describing: twitchLinkArray[twitchLinkArray.count - 1])
                if twitchLinkArray[twitchLinkArray.count - 1].contains("?") {
                    let idArray = twitchLinkArray[twitchLinkArray.count - 1].split(separator: "?")
                    videoId = String(describing: idArray[0])
                }
                Alamofire.request("https://api.twitch.tv/helix/videos?id=\(videoId ?? "")", headers: headers).response {
                    response in
                    guard let data = response.data else { return }
                    if let twitchData = try? JSONDecoder().decode(TwitchResponse.self, from: data) {
                        print(twitchData)
                        self.thumbnailImageView.kf.setImage(with: URL(string: twitchData.data[0].thumbnailUrl.replacingOccurrences(of: "%{width}", with: "175").replacingOccurrences(of: "%{height}", with: "100")))
                    }
                    
                    
    
                    

                }

                
            } else if videoLink.contains("youtu.be") || videoLink.contains("youtube") {
                var youtubeLinkArray = [Substring]()
                var youtubeVideoId = ""
                
                youtubeLinkArray = videoLink.split(separator: "/")
                if youtubeLinkArray[1].contains("youtu.be") {
                    youtubeVideoId = String(describing: youtubeLinkArray[2])
                    youtubeVideoId = String(describing: youtubeVideoId.prefix(11))

                } else if youtubeLinkArray[1].contains("youtube") {
                    print(youtubeLinkArray)
                    if youtubeLinkArray.count == 4 {
                        youtubeLinkArray = youtubeLinkArray[3].split(separator: "=")
                        youtubeVideoId = String(describing: youtubeLinkArray[1].prefix(11))
                        print(youtubeVideoId)

                    }
                    if youtubeLinkArray.count == 3 {
                        youtubeLinkArray = youtubeLinkArray[2].split(separator: "=")
                        youtubeVideoId = String(describing: youtubeLinkArray[1].prefix(11))
                    }

                }
                
                
                let youtubeImageLink = "https://img.youtube.com/vi/\(youtubeVideoId)/hqdefault.jpg"
                
                thumbnailImageView.kf.setImage(with: URL(string: youtubeImageLink))
            } else if videoLink.contains("puu.sh") {
                thumbnailImageView.image = UIImage(named: "Close Button")
            }
        }

    }
    

    @objc func imageViewTapped(gesture: UITapGestureRecognizer) {
        guard let url = URL(string: run!.weblink) else { return }
        presentSafariVC(url: url)
    }
    

    func presentSafariVC(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
