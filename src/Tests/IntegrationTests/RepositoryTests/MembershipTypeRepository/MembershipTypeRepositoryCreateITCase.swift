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

final class MembershipTypeRepositoryCreateITCase: XCTestCase {
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

    func testCreateMembershipType_Success() async throws {
        let mt = MembershipTypeBuilder().build()
            
        try await sut.create(mt)
            
        let createdMt = try await MembershipTypeDBDTO.query(
            on: fixture.db
        ).filter(\.$id == mt.id).first()
        XCTAssertNotNil(createdMt)
        XCTAssertEqual(createdMt?.days, mt.days)
        XCTAssertEqual(createdMt?.name, mt.name)
        XCTAssertEqual(createdMt?.price, mt.price)
        XCTAssertEqual(createdMt?.sessions, mt.sessions)
    }
    
    func testCreateMembershipType_DuplicateName() async throws {
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let mtDuplicateName = MembershipTypeBuilder()
            .withId(UUID())
            .build()

        do {
            try await sut.create(mtDuplicateName)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCreateMembershipType_DuplicateId() async throws {
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let mtDuplicateName = MembershipTypeBuilder()
            .withId(mt.id)
            .withName("Название н2")
            .build()

        do {
            try await sut.create(mtDuplicateName)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
