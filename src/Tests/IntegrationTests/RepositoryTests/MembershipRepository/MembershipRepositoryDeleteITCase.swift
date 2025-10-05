//
//  MembershipTypeRepositoryDeleteITCase.swift
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

final class MembershipRepositoryDeleteITCase: XCTestCase {
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
    
    func testDeleteMembership_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let m = MembershipBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .build()
        try await MembershipDBDTO(from: m).create(on: fixture.db)
        
        try await sut.delete(id: m.id)
        
        let deletedM = try await MembershipDBDTO.query(
            on: fixture.db
        ).filter(\.$id == m.id).first()
        XCTAssertNil(deletedM)
    }
    
    func testDeleteMembership_NotFound() async throws {
        do {
            try await sut.delete(id: UUID())
            XCTFail("Expected MembershipRepositoryError but none was thrown")
        } catch let error as MembershipRepositoryError {
            XCTAssertEqual(MembershipRepositoryError.membershipNotFound, error)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
