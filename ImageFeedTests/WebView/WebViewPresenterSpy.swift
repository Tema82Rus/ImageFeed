//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Artem Yaroshenko on 23.03.2026.
//

import Foundation
import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) { }
    
    func code(from url: URL) -> String? { return nil }
}
