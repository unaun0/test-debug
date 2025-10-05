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

final class MembershipTypeRepositoryFindITCase: XCTestCase {
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
    
    func testFindMembershipTypeById_Success() async throws {
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        
        let foundMt = try await sut.find(id: mt.id)
        
        XCTAssertNotNil(foundMt)
        XCTAssertEqual(mt.name, foundMt?.name)
        XCTAssertEqual(mt.days, foundMt?.days)
        XCTAssertEqual(mt.price, foundMt?.price)
        XCTAssertEqual(mt.sessions, foundMt?.sessions)
    }
    
    func testFindMembershipTypeById_NotFound() async throws {
        let foundMt = try await sut.find(id: UUID())
            
        XCTAssertNil(foundMt)
    }
    
    func testFindMembershipTypeByName_Success() async throws {
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        
        let foundMt = try await sut.find(name: mt.name)
        
        XCTAssertNotNil(foundMt)
        XCTAssertEqual(mt.id, foundMt?.id)
        XCTAssertEqual(mt.days, foundMt?.days)
        XCTAssertEqual(mt.price, foundMt?.price)
        XCTAssertEqual(mt.sessions, foundMt?.sessions)
    }
    
    func testFindMembershipTypeByName_NotFound() async throws {
        let foundMt = try await sut.find(name: "Name")
            
        XCTAssertNil(foundMt)
    }
}
