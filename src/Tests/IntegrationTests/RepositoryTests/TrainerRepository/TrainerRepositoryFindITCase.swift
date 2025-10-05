//
//  TrainerRepositoryFindITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 28.09.2025.
// 

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import Domain
@testable import DataAccess
@testable import TestSupport

final class TrainerRepositoryFindITCase: XCTestCase {
    var fixture: TestAppFixture!
    var sut: TrainerRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        sut = TrainerRepository(db: fixture.db)
        
        try await self.clearDatabase()
    }
    
    override func tearDown() async throws {
        try await self.clearDatabase()
        try await fixture.shutdown()
        
        try await super.tearDown()
    }
    
    private func clearDatabase() async throws {
        try await TrainerDBDTO.query(on: fixture.db).delete()
        try await UserDBDTO.query(on: fixture.db).delete()
    }
    
    func testFindTrainerById_Success() async throws {
        let userId = UUID()
        try await UserDBDTO(
            from: UserBuilder()
                .withId(userId)
                .build()
        ).create(on: fixture.db)
        let trainer = TrainerBuilder().withUserId(userId).build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        
        let foundTrainer = try await sut.find(id: trainer.id)
        
        XCTAssertNotNil(foundTrainer)
        XCTAssertEqual(trainer.userId, foundTrainer?.userId)
        XCTAssertEqual(trainer.description, foundTrainer?.description)
    }
    
    func testFindTrainerById_NotFound() async throws {
        let foundMt = try await sut.find(id: UUID())
            
        XCTAssertNil(foundMt)
    }
    
    func testFindTrainerByUserId_Success() async throws {
        let userId = UUID()
        try await UserDBDTO(
            from: UserBuilder()
                .withId(userId)
                .build()
        ).create(on: fixture.db)
        let trainer = TrainerBuilder().withUserId(userId).build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        
        let foundTrainer = try await sut.find(userId: userId)
        
        XCTAssertNotNil(foundTrainer)
        XCTAssertEqual(trainer.id, foundTrainer?.id)
        XCTAssertEqual(trainer.description, foundTrainer?.description)
    }
    
    func testFindTrainerByUserId_NotFound() async throws {
        let foundMt = try await sut.find(userId: UUID())
            
        XCTAssertNil(foundMt)
    }
}
