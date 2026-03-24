//
//  TableViewSpy.swift
//  ImageFeedTests
//
//  Created by Artem Yaroshenko on 24.03.2026.
//

import UIKit
@testable import ImageFeed

class TableViewMock: UITableView {
    var reloadDataCalled = false
    var insertRowsCalled = false
    var contentInsetSet = false
    var dequeueReusableCellCalled = false
    
    override func reloadData() {
        reloadDataCalled = true
        super.reloadData()
    }
    
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        updates?()
        insertRowsCalled = true
        completion?(true)
        super.performBatchUpdates(updates, completion: completion)
    }
    
    override var contentInset: UIEdgeInsets {
        didSet {
            contentInsetSet = true
        }
    }
    
    override func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}
