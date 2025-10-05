//
//  MembershipRepositoryTests.swift
//  Backend
//
//  Created by Цховребова Яна on 04.05.2025.
//

import Fluent
import Vapor
import XCTest

@testable import Domain
@testable import DataAccess
@testable import TestSupport

final class MembershipRepositoryFixture {
    var app: Application!

    init() {}

    func setUp() async throws {
        app = try await Application.make(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.migrations.add(CreateMembershipTable())
        
        try await app.autoMigrate()
    }

    func shutdown() async throws {
        try await app.asyncShutdown()
        app = nil
    }
}

final class MembershipRepositoryTests: XCTestCase {
    var fixture: MembershipRepositoryFixture!
    var sut: MembershipRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        fixture = MembershipRepositoryFixture()
        try await fixture.setUp()
        sut = MembershipRepository(db: fixture.app.db)
    }

    override func tearDown() async throws {
        try await fixture.shutdown()
        fixture = nil
        try await super.tearDown()
        sut = nil
    }
    
    // MARK: - delete

    func testDeleteMembership_Success() async throws {
        let membership = MembershipBuilder().build()
        try await sut.create(membership)

        try await sut.delete(id: membership.id)

        let fetched = try await sut.find(id: membership.id)
        XCTAssertNil(fetched)
    }

    func testDeleteMembership_NotFound() async throws {
        let membership = MembershipBuilder().build()
        do {
            try await sut.delete(id: membership.id)
            XCTFail("Expected MembershipRepositoryError.membershipNotFound to be thrown")
        } catch let error as MembershipRepositoryError {
            XCTAssertEqual(error, .membershipNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // MARK: - update

    func testUpdateMembership_Success() async throws {
        let membership = MembershipBuilder().build()
        try await sut.create(membership)
        let updatedMembership = MembershipBuilder()
            .withAvailableSessions(10)
            .withId(membership.id)
            .withMembershipTypeId(UUID())
            .withUserId(UUID())
            .build()

        try await sut.update(updatedMembership)

        let fetched = try await sut.find(id: updatedMembership.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, updatedMembership.id)
        XCTAssertEqual(fetched?.availableSessions, updatedMembership.availableSessions)
        XCTAssertEqual(fetched?.membershipTypeId, updatedMembership.membershipTypeId)
        XCTAssertEqual(fetched?.userId, updatedMembership.userId)
    }

    func testUpdateMembership_NotFound() async throws {
        let membership = MembershipBuilder().build()

        do {
            try await sut.update(membership)
            XCTFail("Expected MembershipRepositoryError.membershipNotFound to be thrown")
        } catch let error as MembershipRepositoryError {
            XCTAssertEqual(error, .membershipNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
