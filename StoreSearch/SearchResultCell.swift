//
//  SeatchResultCell.swift
//  StoreSearch
//
//  Created by Alejandro Pallares on 01/08/22.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var artworkImageView: UIImageView!
    
    
    var downloadTask: URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
        selectedBackgroundView = selectedView
        artistNameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        artistNameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        nameLabel.adjustsFontForContentSizeCategory = true
    }
    
    
    
    func configure(for result: SearchResult) {
        nameLabel.text = result.name
        
        if result.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", result.artist, result.type)
        }
        
        artworkImageView.image = UIImage(systemName: "square")
        
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("prepareforreuse happen")
        downloadTask?.cancel()
        downloadTask = nil
    }

}
