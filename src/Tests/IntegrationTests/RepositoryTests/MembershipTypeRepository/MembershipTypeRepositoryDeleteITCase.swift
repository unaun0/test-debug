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

final class MembershipTypeRepositoryDeleteITCase: XCTestCase {
    var fixture: TestAppFixture!
    var sut: MembershipTypeRepository!

    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        sut = MembershipTypeRepository(db: fixture.db)
        
        try await self.clearDatabase()
    }

    override func tearDown() async throws {
        try await self.clearDatabase()
        try await fixture.shutdown()
        
        try await super.tearDown()
    }
    
    private func clearDatabase() async throws {
        try await MembershipTypeDBDTO.query(on: fixture.db).delete()
    }
    
    func testDeleteMembershipType_Success() async throws {
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        
        try await sut.delete(id: mt.id)
        
        let deletedMt = try await MembershipTypeDBDTO.query(
            on: fixture.db
        ).filter(\.$id == mt.id).first()
        XCTAssertNil(deletedMt)
    }
    
    func testDeleteMembershipType_NotFound() async throws {
        do {
            try await sut.delete(id: UUID())
            XCTFail("Expected MembershipTypeRepositoryError but none was thrown")
        } catch let error as MembershipTypeRepositoryError {
            XCTAssertEqual(MembershipTypeRepositoryError.membershipTypeNotFound, error)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
