//
//  TrainingRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 04.05.2025.
//

import Fluent
import Vapor
import XCTest

@testable import Domain
@testable import DataAccess
@testable import TestSupport

final class TrainingRepositoryFixture {
    var app: Application!

    init() {}

    func setUp() async throws {
        app = try await Application.make(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.migrations.add(CreateTrainingTable())
        
        try await app.autoMigrate()
    }

    func shutdown() async throws {
        try await app.asyncShutdown()
        app = nil
    }
}

final class TrainingRepositoryTests: XCTestCase {
    var fixture: TrainingRepositoryFixture!
    var sut: TrainingRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        fixture = TrainingRepositoryFixture()
        try await fixture.setUp()
        sut = TrainingRepository(db: fixture.app.db)
    }

    override func tearDown() async throws {
        sut = nil
        try await fixture.shutdown()
        fixture = nil
        try await super.tearDown()
    }
    
    // MARK: - delete

    func testDeleteTraining_Success() async throws {
        let training = TrainingBuilder().build()
        try await sut.create(training)

        try await sut.delete(id: training.id)

        let fetched = try await sut.find(id: training.id)
        XCTAssertNil(fetched)
    }

    func testDeleteTraining_NotFound() async throws {
        let training = TrainingBuilder().build()
        do {
            try await sut.delete(id: training.id)
            XCTFail("Expected TrainingRepositoryError.trainingNotFound to be thrown")
        } catch let error as TrainingRepositoryError {
            XCTAssertEqual(error, .trainingNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // MARK: - update

    func testUpdateTraining_Success() async throws {
        let training = TrainingBuilder().build()
        try await sut.create(training)
        let updatedTraining = TrainingBuilder()
            .withId(training.id)
            .withRoomId(UUID())
            .withTrainerId(UUID())
            .build()

        try await sut.update(updatedTraining)

        let fetched = try await sut.find(id: training.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, updatedTraining.id)
        XCTAssertEqual(fetched?.roomId, updatedTraining.roomId)
        XCTAssertEqual(fetched?.trainerId, updatedTraining.trainerId)
    }

    func testUpdateTraining_NotFound() async throws {
        let training = TrainingBuilder().build()

        do {
            try await sut.update(training)
            XCTFail("Expected TrainingRepositoryError.trainingNotFound to be thrown")
        } catch let error as TrainingRepositoryError {
            XCTAssertEqual(error, .trainingNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
