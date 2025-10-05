//
//  TrainingRoomRepositoryCreateITCase.swift
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

final class TrainingRoomRepositoryCreateITCase: XCTestCase {
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
    
    func testCreateTrainingRoom_Success() async throws {
        let room = TrainingRoomBuilder().build()
            
        try await sut.create(room)
            
        let createdRoom = try await TrainingRoomDBDTO.query(
            on: fixture.db
        ).filter(\.$id == room.id).first()
        XCTAssertNotNil(createdRoom)
        XCTAssertEqual(createdRoom?.name, room.name)
        XCTAssertEqual(createdRoom?.capacity, room.capacity)
    }
    
    func testCreateTrainingRoom_DublicateName() async throws {
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let anotherRoom = TrainingRoomBuilder().withId(UUID()).build()
           
        do {
            try await sut.create(anotherRoom)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCreateTrainingRoom_DublicateId() async throws {
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let anotherRoom = TrainingRoomBuilder()
            .withId(room.id)
            .withName("Название н2")
            .build()
           
        do {
            try await sut.create(anotherRoom)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
