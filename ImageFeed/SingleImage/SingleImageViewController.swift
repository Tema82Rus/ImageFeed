//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 04.02.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - Property
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    @IBOutlet private var imageView: UIImageView!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
