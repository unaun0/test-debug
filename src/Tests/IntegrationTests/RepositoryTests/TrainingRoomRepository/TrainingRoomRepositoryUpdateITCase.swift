//
//  TrainingRoomRepositoryUpdateITCase.swift
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

final class TrainingRoomRepositoryUpdateITCase: XCTestCase {
    var fixture: TestAppFixture!
    var sut: TrainingRoomRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        sut = TrainingRoomRepository(db: fixture.db)
        
        try await self.clearDatabase()
    }
    
    override func tearDown() async throws {
        try await self.clearDatabase()
        try await fixture.shutdown()
        
        try await super.tearDown()
    }
    
    private func clearDatabase() async throws {
        try await TrainingRoomDBDTO.query(on: fixture.db).delete()
    }
    
    func testUpdateTrainingRoom_Success() async throws {
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let roomUpdateData = TrainingRoomBuilder()
            .withId(room.id)
            .withCapacity(100)
            .withName("trainingRoomName")
            .build()
        
        try await sut.update(roomUpdateData)
        
        let updatedRoom = try await TrainingRoomDBDTO.query(
            on: fixture.db
        ).filter(\.$id == room.id).first()
        XCTAssertNotNil(updatedRoom)
        XCTAssertEqual(updatedRoom?.capacity, roomUpdateData.capacity)
        XCTAssertEqual(updatedRoom?.name, roomUpdateData.name)
    }
    
    func testUpdateTrainingRoom_DublicateName() async throws {
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let anotherRoom = TrainingRoomBuilder()
            .withId(UUID())
            .withName("trainingRoomName")
            .build()
        try await TrainingRoomDBDTO(from: anotherRoom).create(on: fixture.db)
        let roomUpdateData = TrainingRoomBuilder()
            .withId(room.id)
            .withCapacity(100)
            .withName("trainingRoomName")
            .build()
        
        do {
            try await sut.update(roomUpdateData)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUpdateTrainingRoom_NotFound() async throws {
        let room = TrainingRoomBuilder().build()
        
        do {
            try await sut.update(room)
            XCTFail("Expected TrainingRoomRepositoryError but none was thrown")
        } catch let error as TrainingRoomRepositoryError {
            XCTAssertEqual(error, TrainingRoomRepositoryError.trainingRoomNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
