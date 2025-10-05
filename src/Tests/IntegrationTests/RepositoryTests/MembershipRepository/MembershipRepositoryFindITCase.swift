//
//  MembershipTypeRepositoryFindITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 24.09.2025.
//

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import Domain
@testable import DataAccess
@testable import TestSupport

final class MembershipRepositoryFindITCase: XCTestCase {
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
    
    func testFindMembershipById_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let m = MembershipBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .build()
        try await MembershipDBDTO(from: m).create(on: fixture.db)
        
        let foundM = try await sut.find(id: m.id)
        
        XCTAssertNotNil(foundM)
        XCTAssertEqual(foundM?.availableSessions, m.availableSessions)
        XCTAssertEqual(foundM?.membershipTypeId, m.membershipTypeId)
        XCTAssertEqual(foundM?.userId, m.userId)
    }
    
    func testFindMembershipById_NotFound() async throws {
        let foundM = try await sut.find(id: UUID())
            
        XCTAssertNil(foundM)
    }
}
