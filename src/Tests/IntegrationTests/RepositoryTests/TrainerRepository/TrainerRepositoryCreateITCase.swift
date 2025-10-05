//
//  TrainerRepositoryCreateITCase.swift
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

final class TrainerRepositoryCreateITCase: XCTestCase {
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
    
    func testCreateTrainer_Success() async throws {
        let userId = UUID()
        try await UserDBDTO(
            from: UserBuilder()
                .withId(userId)
                .withRole(.trainer)
                .build()
        ).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(userId)
            .build()
        
        try await sut.create(trainer)
        
        let createdTrainer = try await TrainerDBDTO.query(
            on: fixture.db
        ).filter(\.$id == trainer.id).first()
        XCTAssertNotNil(createdTrainer)
        XCTAssertEqual(trainer.userId, createdTrainer?.userId)
        XCTAssertEqual(trainer.description, createdTrainer?.description)
    }
    
    func testCreateTrainer_DublicateUserId() async throws {
        let userId = UUID()
        try await UserDBDTO(
            from: UserBuilder()
                .withId(userId)
                .withRole(.trainer)
                .build()
        ).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(userId)
            .build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        let anotherTrainer = TrainerBuilder()
            .withId(UUID())
            .withUserId(userId)
            .build()
        
        do {
            try await sut.create(anotherTrainer)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCreateTrainer_DublicateId() async throws {
        let userId = UUID(); let anotherUserId = UUID()
        try await UserDBDTO(
            from: UserBuilder()
                .withId(userId)
                .withRole(.trainer)
                .build()
        ).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(userId)
            .build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        try await UserDBDTO(
            from: UserBuilder()
                .withId(anotherUserId)
                .withEmail("email@email.email")
                .withPhoneNumber("+000111000111")
                .withRole(.trainer)
                .build()
        ).create(on: fixture.db)
        let anotherTrainer = TrainerBuilder()
            .withId(trainer.id)
            .withUserId(anotherUserId)
            .build()
        
        do {
            try await sut.create(anotherTrainer)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
