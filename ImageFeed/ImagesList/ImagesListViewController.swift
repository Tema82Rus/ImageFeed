//
//  ViewController.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 28.12.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    // MARK: - Private Properties
    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        imagesListService.fetchPhotosNextPage()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTableViewAnimated),
                                               name: ImagesListService.didChangeNotification,
                                               object: nil)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.fullImageURl = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    //MARK: - Privates Methods
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = photos.count
        photos = imagesListService.photos
        
        guard newCount > oldCount else {
            tableView.reloadData()
            return
        }
        
        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func setupPlaceholder(_ imageView: UIImageView) {
        imageView.contentMode = .center
        imageView.backgroundColor = UIColor.ypWhiteAlpha50IOS
        imageView.clipsToBounds = true
    }
    
}
    // MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        imageListCell.selectionStyle = .none
        imageListCell.dateLabel.isHidden = true
        imageListCell.likeButton.isHidden = true
        
        let photo = photos[indexPath.row]
        let placeholderImage = UIImage(resource: .stub)
        
        if let url = URL(string: photo.thumbImageURL) {
            imageListCell.cellImage.kf.indicatorType = .activity
            setupPlaceholder(imageListCell.cellImage)
            
            imageListCell.cellImage.kf.setImage(with: url,
                                                placeholder: placeholderImage,
                                                options: [
                                                    .transition(.fade(0.25))
                                                ]
            ) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success:
                    imageListCell.likeButton.isHidden = false
                    imageListCell.dateLabel.isHidden = false
                    
                    imageListCell.likeButtonTapped(photo.isLiked)
                    
                    if let date = photo.createdAt {
                        imageListCell.dateLabel.text = self.dateFormatter.string(from: date)
                    } else {
                        imageListCell.dateLabel.text = ""
                    }
                case .failure:
                    print("Ошибка загрузки картинки для ячейки")
                }
            }
        } else {
            imageListCell.cellImage.image = placeholderImage
            setupPlaceholder(imageListCell.cellImage)
        }
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}
// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let screenWidth = tableView.bounds.width
        let size = photo.size.width / screenWidth
        return photo.size.height / size
        
//        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
//        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
//        let imageWidth = photo.size.width
//        let scale = imageViewWidth / imageWidth
//        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
//        return cellHeight
    }
}

////MARK: - ImageListViewController
//extension ImagesListViewController {
//    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
//        let photo = photos[indexPath.row]
//        
//        cell.cellImage.image = image
//        cell.dateLabel.text = dateFormatter.string(from: Date())
//        
//        let isLiked = indexPath.row % 2 == 0
//        let likeImage = isLiked ? UIImage(resource: .favoritesActive) : UIImage(resource: .favoritesNoActive)
//        cell.likeButton.setImage(likeImage, for: .normal)
//    }
//}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        let newLikeState = !photo.isLiked
        imagesListService.changeLike(photoId: photo.id,
                                     isLike: newLikeState) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.likeButtonTapped(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert(error)
                print(error)
            }
        }
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
