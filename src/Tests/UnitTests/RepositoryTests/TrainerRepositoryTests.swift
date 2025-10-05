//
//  TrainerRepository.swift
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

final class TrainerRepositoryFixture {
    var app: Application!

    init() {}

    func setUp() async throws {
        app = try await Application.make(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.migrations.add(CreateTrainerTable())
        
        try await app.autoMigrate()
    }

    func shutdown() async throws {
        try await app.asyncShutdown()
        app = nil
    }
}

final class TrainerRepositoryTests: XCTestCase {
    var fixture: TrainerRepositoryFixture!
    var sut: TrainerRepository!

    override func setUp() async throws {
        try await super.setUp()
        fixture = TrainerRepositoryFixture()
        try await fixture.setUp()
        sut = TrainerRepository(db: fixture.app.db)
    }

    override func tearDown() async throws {
        sut = nil
        try await fixture.shutdown()
        fixture = nil
        try await super.tearDown()
    }
    
    // MARK: - delete

    func testDeleteTrainer_Success() async throws {
        let trainer = TrainerBuilder().build()
        try await sut.create(trainer)

        try await sut.delete(id: trainer.id)

        let fetched = try await sut.find(id: trainer.id)
        XCTAssertNil(fetched)
    }

    func testDeleteTrainer_NotFound() async throws {
        let trainer = TrainerBuilder().build()
        do {
            try await sut.delete(id: trainer.id)
            XCTFail("Expected TrainerRepositoryError.trainerNotFound to be thrown")
        } catch let error as TrainerRepositoryError {
            XCTAssertEqual(error, .trainerNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // MARK: - update

    func testUpdateTrainer_Success() async throws {
        let trainer = TrainerBuilder().build()
        try await sut.create(trainer)
        let updatedTrainer = TrainerBuilder()
            .withId(trainer.id)
            .withDescription("Updated decsription")
            .withUserId(UUID())
            .build()

        try await sut.update(updatedTrainer)

        let fetched = try await sut.find(id: trainer.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, updatedTrainer.id)
        XCTAssertEqual(fetched?.description, updatedTrainer.description)
        XCTAssertEqual(fetched?.userId, updatedTrainer.userId)
    }

    func testUpdateTrainer_NotFound() async throws {
        let trainer = TrainerBuilder().build()

        do {
            try await sut.update(trainer)
            XCTFail("Expected TrainerRepositoryError.trainerNotFound to be thrown")
        } catch let error as TrainerRepositoryError {
            XCTAssertEqual(error, .trainerNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
