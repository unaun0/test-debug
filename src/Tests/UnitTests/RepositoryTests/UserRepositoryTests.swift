//
//  UserRepositoryTests.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Fluent
import Vapor
import XCTest

@testable import DataAccess
@testable import Domain
@testable import TestSupport


final class UserRepositoryFixture {
    var app: Application!

    init() {}

    func setUp() async throws {
        app = try await Application.make(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.migrations.add(CreateUserTable())
        
        try await app.autoMigrate()
    }

    func shutdown() async throws {
        try await app.asyncShutdown()
        app = nil
    }
}

final class UserRepositoryTests: XCTestCase {
    var fixture: UserRepositoryFixture!
    var sut: UserRepository!

    override func setUp() async throws {
        try await super.setUp()
        fixture = UserRepositoryFixture()
        try await fixture.setUp()
        sut = UserRepository(db: fixture.app.db)
    }

    override func tearDown() async throws {
        sut = nil
        try await fixture.shutdown()
        fixture = nil
        try await super.tearDown()
    }

    // MARK: - delete

    func testDeleteUser_Success() async throws {
        let user = UserBuilder().build()
        try await sut.create(user)

        try await sut.delete(id: user.id)

        let fetched = try await sut.find(id: user.id)
        XCTAssertNil(fetched)
    }

    func testDeleteUser_NotFound() async throws {
        let user = UserBuilder().build()
        do {
            try await sut.delete(id: user.id)
            XCTFail("Expected UserRepositoryError.userNotFound to be thrown")
        } catch let error as UserRepositoryError {
            XCTAssertEqual(error, .userNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // MARK: - update

    func testUpdateUser_Success() async throws {
        let user = UserBuilder().build()
        try await sut.create(user)
        let updatedUser = UserBuilder()
            .withId(user.id)
            .withEmail("updated@example.com")
            .withPhoneNumber("+9999999999")
            .withPassword("newPassword123")
            .withFirstName("UpdatedFirst")
            .withLastName("UpdatedLast")
            .withBirthDate(Date().yearsAgo(65))
            .withGender(.female)
            .withRole(.admin)
            .build()

        try await sut.update(updatedUser)

        let fetched = try await sut.find(id: user.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, user.id)
        XCTAssertEqual(fetched?.email, updatedUser.email)
        XCTAssertEqual(fetched?.phoneNumber, updatedUser.phoneNumber)
    }

    func testUpdateUser_NotFound() async throws {
        let user = UserBuilder().build()

        do {
            try await sut.update(user)
            XCTFail("Expected UserError.userNotFound to be thrown")
        } catch let error as UserRepositoryError {
            XCTAssertEqual(error, .userNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
