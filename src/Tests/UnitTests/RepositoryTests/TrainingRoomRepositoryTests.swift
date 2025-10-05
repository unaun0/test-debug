//
//  TrainingRoomRepositoryTests.swift
//  Backend
//
//  Created by Цховребова Яна on 04.05.2025.
//

import Fluent
import FluentSQLiteDriver
import PostgresNIO
import Vapor
import XCTest

@testable import Domain
@testable import DataAccess
@testable import TestSupport

final class TrainingRoomRepositoryFixture {
    var app: Application!

    init() {}

    func setUp() async throws {
        app = try await Application.make(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.migrations.add(CreateTrainingRoomTable())
        
        try await app.autoMigrate()
    }

    func shutdown() async throws {
        try await app.asyncShutdown()
        app = nil
    }
}

final class TrainingRoomRepositoryTests: XCTestCase {
    var fixture: TrainingRoomRepositoryFixture!
    var sut: TrainingRoomRepository!

    override func setUp() async throws {
        try await super.setUp()
        fixture = TrainingRoomRepositoryFixture()
        try await fixture.setUp()
        sut = TrainingRoomRepository(db: fixture.app.db)
    }

    override func tearDown() async throws {
        sut = nil
        try await fixture.shutdown()
        fixture = nil
        try await super.tearDown()
    }

    // MARK: - delete

    func testDeleteTrainingRoom_Success() async throws {
        let room = TrainingRoomBuilder().build()
        try await sut.create(room)
        
        try await sut.delete(id: room.id)
        
        let fetched = try await sut.find(id: room.id)
        XCTAssertNil(fetched)
    }

    func testDeleteTrainingRoom_NotFound() async throws {
        let room = TrainingRoomBuilder().build()
        do {
            try await sut.delete(id: room.id)
            XCTFail("Expected TrainingRoomRepositoryError.trainingRoomNotFound to be thrown")
        } catch let error as TrainingRoomRepositoryError {
            XCTAssertEqual(error, .trainingRoomNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    // MARK: - update
    
    func testUpdateTrainingRoom_Success() async throws {
        let room = TrainingRoomBuilder().build()
        try await sut.create(room)
        let updatedRoom = TrainingRoomBuilder()
            .withId(room.id)
            .withCapacity(100)
            .withName("Зал №10")
            .build()
        
        try await sut.update(updatedRoom)
        
        let fetched = try await sut.find(id: room.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, updatedRoom.id)
        XCTAssertEqual(fetched?.capacity, updatedRoom.capacity)
        XCTAssertEqual(fetched?.name, updatedRoom.name)
    }

    func testUpdateTrainingRoom_NotFound() async throws {
        let room = TrainingRoomBuilder().build()
        
        do {
            try await sut.update(room)
            XCTFail("Expected TrainingRoomRepositoryError.trainingRoomNotFound to be thrown")
        } catch let error as TrainingRoomRepositoryError {
            XCTAssertEqual(error, .trainingRoomNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

}
