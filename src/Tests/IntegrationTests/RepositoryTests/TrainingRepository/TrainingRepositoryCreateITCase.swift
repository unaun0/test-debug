//
//  TrainingRepositoryCreateITCase.swift
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

final class TrainingRepositoryCreateITCase: XCTestCase {
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

    func testCreateTraining_Success() async throws {
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
            
        try await sut.create(training)
            
        let createdTraining = try await TrainingDBDTO.query(
            on: fixture.db
        ).filter(\.$id == training.id).first()
        XCTAssertNotNil(createdTraining)
        XCTAssertEqual(createdTraining?.date, training.date)
        XCTAssertEqual(createdTraining?.roomId, training.roomId)
        XCTAssertEqual(createdTraining?.trainerId, training.trainerId)
    }
    
    func testCreateTraining_DuplicateId() async throws {
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
            
        do {
            try await sut.create(training)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
