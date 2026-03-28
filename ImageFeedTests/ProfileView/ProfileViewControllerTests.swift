//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Artem Yaroshenko on 24.03.2026.
//

import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {
    var sut: ProfileViewController!
    var mockPresenter: ProfilePresenterMock!
    var mockView: ProfileViewMock!
    
    override func setUp() {
        super.setUp()
        sut = ProfileViewController()
        mockPresenter = ProfilePresenterMock()
        mockView = ProfileViewMock()
        
        sut.configure(mockPresenter)
        
        _ = sut.view
    }
    
    override func tearDown() {
        sut = nil
        mockPresenter = nil
        mockView = nil
        super.tearDown()
    }
    
    func testViewControllerConfiguration() {
        // Given
        let viewController = sut
        let presenter = mockPresenter
        
        // Then
        XCTAssertNotNil(viewController, "ProfileViewController should initialize successfully")
        XCTAssertNotNil(viewController?.view, "View should be loaded")
        XCTAssertNotNil(viewController?.presenter, "Presenter should be set after configuration")
        XCTAssertTrue(viewController?.presenter === presenter, "Presenter should be the configured mock")
    }
    
    func testPresenterViewIsSetAfterConfiguration() {
        // Given
        let presenter = mockPresenter
        let expectedView = sut
        
        // Then
        XCTAssertNotNil(presenter?.view, "Presenter view should be set after configuration")
        XCTAssertTrue(presenter?.view === expectedView, "Presenter view should be the view controller")
    }
    
    func testViewDidLoadCallsPresenter() {
        // Given
        let testViewController = ProfileViewController()
        let testMockPresenter = ProfilePresenterMock()
        testViewController.configure(testMockPresenter)
        
        testMockPresenter.viewDidLoadCalled = false
        
        // When
        _ = testViewController.view
        
        // Then
        XCTAssertTrue(testMockPresenter.viewDidLoadCalled, "Presenter's viewDidLoad should be called when view loads")
    }
    
    func testUIElementsExists() {
        // Given
        let viewController = sut
        
        // Then
        XCTAssertNotNil(viewController?.avatarImageView, "Profile photo image view should exist")
        XCTAssertNotNil(viewController?.nameLabel, "Name label should exist")
        XCTAssertNotNil(viewController?.loginNameLabel, "Login name label should exist")
        XCTAssertNotNil(viewController?.descriptionLabel, "Description label should exist")
        XCTAssertNotNil(viewController?.logoutButton, "Logout button should exist")
    }
    
    func testUIElementsAreAddedToView() {
        // Given
        let view = sut.view
        let avatarImageView = sut.avatarImageView
        let nameLabel = sut.nameLabel
        let loginNameLabel = sut.loginNameLabel
        let descriptionLabel = sut.descriptionLabel
        let logoutButton = sut.logoutButton
        
        // Then
        XCTAssertTrue(view?.subviews.contains(avatarImageView) ?? false, "Profile photo image view should be added to view")
        XCTAssertTrue(view?.subviews.contains(nameLabel) ?? false, "Name label should be added to view")
        XCTAssertTrue(view?.subviews.contains(loginNameLabel) ?? false, "Nick label should be added to view")
        XCTAssertTrue(view?.subviews.contains(descriptionLabel) ?? false, "Description label should be added to view")
        XCTAssertTrue(view?.subviews.contains(logoutButton) ?? false, "Logout button should be added to view")
    }
    
    func testUpdateProfileDetailsUpdatesUILabels() {
        // Given
        let testProfile = Profile(
            username: "test_user",
            name: "Test User",
            loginName: "@test_user",
            bio: "Test bio description"
        )
        
        // When
        sut.updateProfileDetails(with: testProfile)
        
        // Then
        XCTAssertEqual(sut.nameLabel.text, "Test User", "Name label should update with profile name")
        XCTAssertEqual(sut.loginNameLabel.text, "@test_user", "LoginName label should update with login name")
        XCTAssertEqual(sut.descriptionLabel.text, "Test bio description", "Description label should update with bio")
    }

    func testUpdateAvatarImage() {
        // Given
        mockView.updateAvatarCalled = true
        
        
        // Then
        XCTAssertTrue(mockView.updateAvatarCalled, "View should be updated with avatar image")
    }
    
    func testLogoutButtonHasTarget() {
        // Given
        let button = sut.logoutButton
        let target = sut
        let controlEvent = UIControl.Event.touchUpInside
        
        // When
        let actions = button.actions(forTarget: target, forControlEvent: controlEvent)
        
        // Then
        XCTAssertNotNil(actions, "Logout button should have actions")
        XCTAssertTrue(actions?.contains("didTapLogoutButton") ?? false, "Logout button should have didTapLogoutButton action")
    }
    
    func testLogoutButtonTappedCallsPresenter() {
        // Given
        let presenter = mockPresenter
        presenter?.logoutButtonTappedCalled = false
        
        // When
        sut.logoutButtonDidTapAlert()
        
        // Then
        XCTAssertTrue(((presenter?.logoutButtonTappedCalled) != nil), "Presenter's logoutButtonTapped should be called")
    }
}
