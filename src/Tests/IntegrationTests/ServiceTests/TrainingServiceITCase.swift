//
//  TrainingServiceITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 29.09.2025.
//

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import Domain
@testable import DataAccess
@testable import TestSupport

final class TrainingServiceITCase: XCTestCase {
    var fixture: TestAppFixture!
    var repo: ITrainingRepository!
    var sut: TrainingService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        repo = TrainingRepository(db: fixture.db)
        sut = TrainingService(repository: repo)
        
        try await self.clearDatabase()
    }
    
    override func tearDown() async throws {
        try await self.clearDatabase()
        try await fixture.shutdown()

        try await super.tearDown()
    }
    
    private func clearDatabase() async throws {
        try await TrainingDBDTO.query(on: fixture.db).delete()
        try await TrainerDBDTO.query(on: fixture.db).delete()
        try await UserDBDTO.query(on: fixture.db).delete()
        try await TrainingRoomDBDTO.query(on: fixture.db).delete()
    }
    
    // MARK: - create

    func testCreateTraining_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(user.id)
            .build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let dto = TrainingCreateDTOBuilder()
            .withRoomId(room.id)
            .withTrainerId(trainer.id)
            .build()
        
        let training = try await sut.create(dto)

        XCTAssertNotNil(training)
        XCTAssertEqual(training?.roomId, dto.roomId)
        XCTAssertEqual(training?.trainerId, dto.trainerId)
        XCTAssertEqual(
            training?.date,
            dto.date?.toDate(
                format: ValidationRegex.DateFormat.format
            )
        )
    }
    
    func testCreateTraining_InvalidDate_Throws() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(user.id)
            .build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let dto = TrainingCreateDTOBuilder()
            .withRoomId(room.id)
            .withTrainerId(trainer.id)
            .withDate("invalid date")
            .build()

        do {
            _ = try await sut.create(dto)
            XCTFail("Expected TrainingError.invalidDate to be thrown")
        } catch let error as TrainingError {
            XCTAssertEqual(error, .invalidDate)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - update

    func testUpdateTraining_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(user.id)
            .build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let existingTraining = TrainingBuilder()
            .withRoomId(room.id)
            .withTrainerId(trainer.id)
            .build()
        try await TrainingDBDTO(from: existingTraining).create(on: fixture.db)
        let dto = TrainingUpdateDTOBuilder()
            .withDate("2030-09-07 12:00:00")
            .withRoomId(room.id)
            .withTrainerId(trainer.id)
            .build()
        
        let training = try await sut.update(
            id: existingTraining.id,
            with: dto
        )

        XCTAssertNotNil(training)
        XCTAssertEqual(training?.id, existingTraining.id)
        XCTAssertEqual(training?.roomId, dto.roomId)
        XCTAssertEqual(training?.trainerId, dto.trainerId)
        XCTAssertEqual(
            training?.date,
            dto.date?.toDate(
                format: ValidationRegex.DateFormat.format
            )!
        )
    }

    func testUpdateTraining_NotFound() async {
        let dto = TrainingUpdateDTOBuilder().build()

        do {
            _ = try await sut.update(id: UUID(), with: dto)
            XCTFail("Expected TrainingError.trainerNotFound")
        } catch let error as TrainingError {
            XCTAssertEqual(error, .trainerNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - delete

    func testDeleteTraining_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(user.id)
            .build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let existingTraining = TrainingBuilder()
            .withRoomId(room.id)
            .withTrainerId(trainer.id)
            .build()
        try await TrainingDBDTO(from: existingTraining).create(on: fixture.db)

        try await sut.delete(id: existingTraining.id)

        let deletedTraining = try await UserDBDTO.query(
            on: fixture.db
        ).filter(\.$id == existingTraining.id).first()
        XCTAssertNil(deletedTraining)
    }

    func testDeleteTraining_NotFound() async throws {
        let trainingId = UUID()

        do {
            try await sut.delete(id: trainingId)
            XCTFail("Expected TrainingError.trainingNotFound")
        } catch let error as TrainingError {
            XCTAssertEqual(error, .trainingNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
