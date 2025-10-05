//
//  TrainingRepositoryUpdateITCase.swift
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

final class TrainingRepositoryUpdateITCase: XCTestCase {
    var fixture: TestAppFixture!
    var sut: TrainingRepository!

    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        sut = TrainingRepository(db: fixture.db)
        
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

    func testUpdateTraining_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(user.id)
            .build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let training = TrainingBuilder()
            .withRoomId(room.id)
            .withTrainerId(trainer.id)
            .build()
        try await TrainingDBDTO(from: training).create(on: fixture.db)
        
        let trainingUpdateData = TrainingBuilder()
            .withId(training.id)
            .withRoomId(room.id)
            .withTrainerId(trainer.id)
            .build()
        
        try await sut.update(trainingUpdateData)
            
        let updatedTraining = try await TrainingDBDTO.query(
            on: fixture.db
        ).filter(\.$id == training.id).first()
        XCTAssertNotNil(updatedTraining)
        XCTAssertEqual(updatedTraining?.date.onlyDate, training.date.onlyDate)
        XCTAssertEqual(updatedTraining?.roomId, training.roomId)
        XCTAssertEqual(updatedTraining?.trainerId, training.trainerId)
    }
    
    func testUpdateTraining_TrainingNotFound() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(user.id)
            .build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let training = TrainingBuilder()
            .withRoomId(room.id)
            .withTrainerId(trainer.id)
            .build()
        
        do {
            try await sut.update(training)
            XCTFail("Expected UserRepositoryError but none was thrown")
        } catch let error as TrainingRepositoryError {
            XCTAssertEqual(TrainingRepositoryError.trainingNotFound, error)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
