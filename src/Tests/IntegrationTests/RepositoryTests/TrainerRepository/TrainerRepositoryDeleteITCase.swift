//
//  TrainerRepositoryDeleteITCase.swift
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

final class TrainerRepositoryDeleteITCase: XCTestCase {
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
    
    func testDeleteTrainer_Success() async throws {
        let userId = UUID()
        try await UserDBDTO(
            from: UserBuilder()
                .withId(userId)
                .build()
        ).create(on: fixture.db)
        let trainer = TrainerBuilder().withUserId(userId).build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        
        try await sut.delete(id: trainer.id)
        
        let deletedTrainer = try await TrainerDBDTO.query(
            on: fixture.db
        ).filter(\.$id == trainer.id).first()
        XCTAssertNil(deletedTrainer)
    }
    
    func testDeleteTrainer_NotFound() async throws {
        do {
            try await sut.delete(id: UUID())
            XCTFail("Expected TrainerRepositoryError but none was thrown")
        } catch let error as TrainerRepositoryError {
            XCTAssertEqual(TrainerRepositoryError.trainerNotFound, error)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
