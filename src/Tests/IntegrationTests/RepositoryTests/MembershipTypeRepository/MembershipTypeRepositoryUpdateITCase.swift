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

final class MembershipTypeRepositoryUpdateITCase: XCTestCase {
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

    func testUpdateMembershipType_Success() async throws {
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let mtUpdateData = MembershipTypeBuilder()
            .withId(mt.id)
            .withName("NameName")
            .withPrice(100.100)
            .withSessions(100)
            .withDays(100)
            .build()
            
        try await sut.update(mtUpdateData)
        
        let updatedMt = try await MembershipTypeDBDTO.query(
            on: fixture.db
        ).filter(\.$id == mt.id).first()
        XCTAssertNotNil(updatedMt)
        XCTAssertEqual(updatedMt?.days, mtUpdateData.days)
        XCTAssertEqual(updatedMt?.name, mtUpdateData.name)
        XCTAssertEqual(updatedMt?.price, mtUpdateData.price)
        XCTAssertEqual(updatedMt?.sessions, mtUpdateData.sessions)
    }
    
    func testUpdateMembershipType_DuplicateName() async throws {
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let anotherMt = MembershipTypeBuilder()
            .withId(UUID())
            .withName("NameName")
            .build()
        try await MembershipTypeDBDTO(from: anotherMt).create(on: fixture.db)
        let mtUpdateData = MembershipTypeBuilder()
            .withId(mt.id)
            .withName("NameName")
            .build()

        do {
            try await sut.update(mtUpdateData)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUpdateMembershipType_NotFound() async throws {
        let mt = MembershipTypeBuilder().build()
        
        do {
            try await sut.update(mt)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as MembershipTypeRepositoryError {
            XCTAssertEqual(error, MembershipTypeRepositoryError.membershipTypeNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
