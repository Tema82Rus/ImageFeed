//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 26.01.2026.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    // MARK: - IB Actions
    @IBAction private func likeButtonDidTap(_ sender: UIButton) {
        delegate?.imagesListCellDidTapLike(self)
    }
    // MARK: - Private Properties
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        contentView.frame = contentView.frame.inset(by: padding)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        likeButton.isHidden = true
        dateLabel.isHidden = true
        
    }
    //MARK: - Methods
    func setIsLiked(_ isLiked: Bool) {
        let image = UIImage(resource: isLiked ? .favoritesActive : .favoritesNoActive)
        
        likeButton.setImage(image, for: .normal)
    }
}
