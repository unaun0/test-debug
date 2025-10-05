//
//  MembershipTypeRepositoryTests.swift
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

final class MembershipTypeRepositoryFixture {
    var app: Application!

    init() {}

    func setUp() async throws {
        app = try await Application.make(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.migrations.add(CreateMembershipTypeTable())
        
        try await app.autoMigrate()
    }

    func shutdown() async throws {
        try await app.asyncShutdown()
        app = nil
    }
}

final class MembershipTypeRepositoryTests: XCTestCase {
    var fixture: MembershipTypeRepositoryFixture!
    var sut: MembershipTypeRepository!

    override func setUp() async throws {
        try await super.setUp()
        fixture = MembershipTypeRepositoryFixture()
        try await fixture.setUp()
        sut = MembershipTypeRepository(db: fixture.app.db)
    }

    override func tearDown() async throws {
        sut = nil
        try await fixture.shutdown()
        fixture = nil
        try await super.tearDown()
    }
    
    // MARK: - delete

    func testDeleteMembershipType_Success() async throws {
        let type = MembershipTypeBuilder().build()
        try await sut.create(type)

        try await sut.delete(id: type.id)

        let fetched = try await sut.find(id: type.id)
        XCTAssertNil(fetched)
    }

    func testDeleteMembershipType_NotFound() async throws {
        let type = MembershipTypeBuilder().build()
        do {
            try await sut.delete(id: type.id)
            XCTFail("Expected MembershipTypeRepositoryError.membershipTypeNotFound to be thrown")
        } catch let error as MembershipTypeRepositoryError {
            XCTAssertEqual(error, .membershipTypeNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // MARK: - update

    func testUpdateMembershipType_Success() async throws {
        let type = MembershipTypeBuilder().build()
        try await sut.create(type)
        let updatedType = MembershipTypeBuilder()
            .withId(type.id)
            .withDays(365)
            .withName("Name123")
            .withPrice(12345)
            .withSessions(365)
            .build()

        try await sut.update(updatedType)

        let fetched = try await sut.find(id: type.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, updatedType.id)
        XCTAssertEqual(fetched?.sessions, updatedType.sessions)
        XCTAssertEqual(fetched?.days, updatedType.days)
        XCTAssertEqual(fetched?.name, updatedType.name)
        XCTAssertEqual(fetched?.price, updatedType.price)
    }

    func testUpdateMembershipType_NotFound() async throws {
        let type = MembershipTypeBuilder().build()

        do {
            try await sut.update(type)
            XCTFail("Expected MembershipTypeRepositoryError.membershipTypeNotFound to be thrown")
        } catch let error as MembershipTypeRepositoryError {
            XCTAssertEqual(error, .membershipTypeNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
