//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 26.01.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Property
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
}
