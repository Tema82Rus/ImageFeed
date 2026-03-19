//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 26.01.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    // MARK: - Private Properties
    static let reuseIdentifier = "ImagesListCell"
}
