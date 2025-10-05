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

final class TrainerRepositoryUpdateITCase: XCTestCase {
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
    
    func testUpdateTrainer_Success() async throws {
        let userId = UUID()
        let anotherUserId = UUID()
        let trainerId = UUID()
        try await UserDBDTO(
            from: UserBuilder()
                .withId(userId)
                .withRole(.trainer)
                .build()
        ).create(on: fixture.db)
        try await TrainerDBDTO(
            from: TrainerBuilder()
                .withId(trainerId)
                .withUserId(userId)
                .build()
        ).create(on: fixture.db)
        try await UserDBDTO(
            from: UserBuilder()
                .withId(anotherUserId)
                .withRole(.trainer)
                .withEmail("email@email.email")
                .withPhoneNumber("+000111000111")
                .build()
        ).create(on: fixture.db)
        let trainerUpdateData = TrainerBuilder()
            .withId(trainerId)
            .withUserId(anotherUserId)
            .withDescription("Описание новое.")
            .build()
        
        try await sut.update(trainerUpdateData)
        
        let createdTrainer = try await TrainerDBDTO.query(
            on: fixture.db
        ).filter(\.$id == trainerId).first()
        XCTAssertNotNil(createdTrainer)
        XCTAssertEqual(trainerUpdateData.userId, createdTrainer?.userId)
        XCTAssertEqual(trainerUpdateData.description, createdTrainer?.description)
    }
    
    func testUpdateTrainer_DublicateUserId() async throws {
        let userId = UUID()
        let anotherUserId = UUID()
        let trainerId = UUID()
        try await UserDBDTO(
            from: UserBuilder()
                .withId(userId)
                .withRole(.trainer)
                .build()
        ).create(on: fixture.db)
        try await TrainerDBDTO(
            from: TrainerBuilder()
                .withId(trainerId)
                .withUserId(userId)
                .build()
        ).create(on: fixture.db)
        try await UserDBDTO(
            from: UserBuilder()
                .withId(anotherUserId)
                .withRole(.trainer)
                .withEmail("email@email.email")
                .withPhoneNumber("+000111000111")
                .build()
        ).create(on: fixture.db)
        try await TrainerDBDTO(
            from: TrainerBuilder()
                .withUserId(anotherUserId)
                .build()
        ).create(on: fixture.db)
        let trainerUpdateData = TrainerBuilder()
            .withId(trainerId)
            .withUserId(anotherUserId)
            .withDescription("Описание новое.")
            .build()
        
        do {
            try await sut.update(trainerUpdateData)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
