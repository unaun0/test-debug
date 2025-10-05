//
//  MembershipTypeRepositoryCreateITCase.swift
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

final class MembershipRepositoryCreateITCase: XCTestCase {
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

    func testCreateMembership_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let m = MembershipBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .build()
            
        try await sut.create(m)
            
        let createdM = try await MembershipDBDTO.query(
            on: fixture.db
        ).filter(\.$id == m.id).first()
        XCTAssertNotNil(createdM)
        XCTAssertEqual(createdM?.availableSessions, m.availableSessions)
        XCTAssertEqual(createdM?.membershipTypeId, m.membershipTypeId)
        XCTAssertEqual(createdM?.userId, m.userId)
    }
    
    func testCreateMembership_DuplicateId() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let m = MembershipBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .build()
        try await MembershipDBDTO(from: m).create(on: fixture.db)

        do {
            try await sut.create(m)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
