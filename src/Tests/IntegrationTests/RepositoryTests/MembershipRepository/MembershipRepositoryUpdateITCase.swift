//
//  MembershipTypeRepositoryUpdateITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 24.09.2025.
//

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import DataAccess
@testable import TestSupport

final class MembershipRepositoryUpdateITCase: XCTestCase {
    var fixture: TestAppFixture!
    var sut: MembershipRepository!

    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        sut = MembershipRepository(db: fixture.db)
        
        try await self.clearDatabase()
    }

    override func tearDown() async throws {
        try await self.clearDatabase()
        try await fixture.shutdown()
        
        try await super.tearDown()
    }
    
    private func clearDatabase() async throws {
        try await MembershipDBDTO.query(on: fixture.db).delete()
        try await MembershipTypeDBDTO.query(on: fixture.db).delete()
        try await UserDBDTO.query(on: fixture.db).delete()
    }

    func testUpdateMembership_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let m = MembershipBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .build()
        try await MembershipDBDTO(from: m).create(on: fixture.db)
        let mUpdateData = MembershipBuilder()
            .withId(m.id)
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .build()
        
        try await sut.update(mUpdateData)
        
        let updatedM = try await MembershipDBDTO.query(
            on: fixture.db
        ).filter(\.$id == m.id).first()
        XCTAssertNotNil(updatedM)
        XCTAssertEqual(updatedM?.userId, mUpdateData.userId)
        XCTAssertEqual(updatedM?.membershipTypeId, mUpdateData.membershipTypeId)
        XCTAssertEqual(updatedM?.availableSessions, mUpdateData.availableSessions)
    }

    func testUpdateMembership_NotFound() async throws {
        let m = MembershipBuilder().build()
        
        do {
            try await sut.update(m)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as MembershipRepositoryError {
            XCTAssertEqual(error, MembershipRepositoryError.membershipNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
