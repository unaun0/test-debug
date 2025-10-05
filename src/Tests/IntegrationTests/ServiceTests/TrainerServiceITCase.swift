//
//  TrainerServiceITCase.swift
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

final class TrainerServiceITCase: XCTestCase {
    var fixture: TestAppFixture!
    var repo: ITrainerRepository!
    var sut: TrainerService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        repo = TrainerRepository(db: fixture.db)
        sut = TrainerService(repository: repo)
        
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
    
    // MARK: - create

    func testCreateTrainer_Success() async throws {
        let user = UserBuilder().withRole(.trainer).build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let dto = TrainerCreateDTOBuilder().withUserId(user.id).build()

        let trainer = try await sut.create(dto)

        XCTAssertNotNil(trainer)
        XCTAssertEqual(trainer?.userId, dto.userId)
        XCTAssertEqual(trainer?.description, dto.description)
    }

    func testCreateTrainer_UserAlreadyHasTrainer() async throws {
        let user = UserBuilder().withRole(.trainer).build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let existingTrainer = TrainerBuilder().withUserId(user.id).build()
        try await TrainerDBDTO(from: existingTrainer).create(on: fixture.db)
        let dto = TrainerCreateDTOBuilder().withUserId(user.id).build()

        do {
            _ = try await sut.create(dto)
            XCTFail("Expected TrainerError.userAlreadyHasTrainer")
        } catch let error as TrainerError {
            XCTAssertEqual(error, .userAlreadyHasTrainer)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - update

    func testUpdateTrainer_Success() async throws {
        let user = UserBuilder().withRole(.trainer).build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let existingTrainer = TrainerBuilder().withUserId(user.id).build()
        try await TrainerDBDTO(from: existingTrainer).create(on: fixture.db)
        let dto = TrainerUpdateDTOBuilder()
            .withDescription("Updated description")
            .build()
      
        let result = try await sut.update(id: existingTrainer.id, with: dto)

        XCTAssertEqual(result?.id, existingTrainer.id)
        XCTAssertEqual(result?.description, dto.description)
    }

    func testUpdateTrainer_NotFound() async throws {
        let dto = TrainerUpdateDTOBuilder().build()

        do {
            _ = try await sut.update(id: UUID(), with: dto)
            XCTFail("Expected TrainerError.trainerNotFound")
        } catch let error as TrainerError {
            XCTAssertEqual(error, .trainerNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - delete
    
    func testDeleteTrainer_Success() async throws {
        let user = UserBuilder().withRole(.trainer).build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let existingTrainer = TrainerBuilder().withUserId(user.id).build()
        try await TrainerDBDTO(from: existingTrainer).create(on: fixture.db)
        
        try await sut.delete(id: existingTrainer.id)

        let deletedTrainer = try await TrainerDBDTO.query(
            on: fixture.db
        ).filter(\.$id == existingTrainer.id).first()
        XCTAssertNil(deletedTrainer)
    }
    
    func testDeleteTrainer_NotFound() async throws {
        let trainerId = UUID()

        do {
            try await sut.delete(id: trainerId)
            XCTFail("Expected TrainerError.trainerNotFound")
        } catch let error as TrainerError {
            XCTAssertEqual(error, .trainerNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
