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

final class TrainingRepositoryFindITCase: XCTestCase {
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

    func testFindTrainingById_Success() async throws {
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
        
        let foundTraining = try await sut.find(id: training.id)
            
        XCTAssertNotNil(foundTraining)
        XCTAssertEqual(training.roomId, foundTraining?.roomId)
        XCTAssertEqual(training.trainerId, foundTraining?.trainerId)
        XCTAssertEqual(training.date, foundTraining?.date)
    }
    
    func testFindTrainingById_NotFound() async throws {
        let foundTraining = try await sut.find(id: UUID())
        
        XCTAssertNil(foundTraining)
    }
    
    func testFindTrainingByRoomId_Success() async throws {
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
        
        let foundTrainings = try await sut.find(trainingRoomId: room.id)
            
        XCTAssertFalse(foundTrainings.isEmpty)
        XCTAssertEqual(foundTrainings.count, 1)
        let foundTraining = foundTrainings.first
        XCTAssertEqual(training.roomId, foundTraining?.roomId)
        XCTAssertEqual(training.trainerId, foundTraining?.trainerId)
        XCTAssertEqual(training.date, foundTraining?.date)
    }
    
    func testFindTrainingByRoomId_NotFound() async throws {
        let foundTrainings = try await sut.find(trainingRoomId: UUID())
        
        XCTAssertTrue(foundTrainings.isEmpty)
    }
    
    func testFindTrainingByTrainerId_Success() async throws {
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
        
        let foundTrainings = try await sut.find(trainerId: trainer.id)
            
        XCTAssertFalse(foundTrainings.isEmpty)
        XCTAssertEqual(foundTrainings.count, 1)
        let foundTraining = foundTrainings.first
        XCTAssertEqual(training.roomId, foundTraining?.roomId)
        XCTAssertEqual(training.trainerId, foundTraining?.trainerId)
        XCTAssertEqual(training.date, foundTraining?.date)
    }
    
    func testFindTrainingByTrainerId_NotFound() async throws {
        let foundTrainings = try await sut.find(trainerId: UUID())
        
        XCTAssertTrue(foundTrainings.isEmpty)
    }
}
