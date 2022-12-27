//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Alejandro Pallares on 14/10/22.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!

    var downloadTask: URLSessionDownloadTask?
    var searchResult: SearchResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        popupView.layer.cornerRadius = 10
        
        if searchResult != nil {
            updateUI()
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        //GradientView
        view.backgroundColor = UIColor.clear
        let dimmingView = GradientView(frame: CGRect.zero)
        dimmingView.frame = view.bounds
        view.insertSubview(dimmingView, at: 0)
    }
    
    
    enum AnimationStyle {
        case slide
        case fade
    }
    
    var dissmissStyle = AnimationStyle.fade
    
    func updateUI() {
        nameLabel.text = searchResult.name
        
        if searchResult.artist.isEmpty {
            artistNameLabel.text = "UnKnown"
        } else {
            artistNameLabel.text = searchResult.artist
        }
    
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        let priceText: String
        
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        //get the image
        if let largeUrl = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeUrl)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      transitioningDelegate = self
    }
    
    deinit {
        print("deinit: \(self)")
        downloadTask?.cancel()
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func close() {
        dissmissStyle = .slide
        dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController,
        source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(
        forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            switch dissmissStyle {
            case.slide:
                return SlideOutAnimationController()
            case .fade:
                return FadeOutAnimationController()
        }
    }
}
