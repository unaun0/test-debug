//
//  TrainingRoomRepositoryFindITCase.swift
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

final class TrainingRoomRepositoryFindITCase: XCTestCase {
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
    
    func testFindTrainingRoomById_Success() async throws {
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        
        let foundRoom = try await sut.find(id: room.id)
        
        XCTAssertNotNil(foundRoom)
        XCTAssertEqual(foundRoom?.capacity, room.capacity)
        XCTAssertEqual(foundRoom?.name, room.name)
    }
    
    func testFindTrainingRoomById_NotFound() async throws {
        let foundRoom = try await sut.find(id: UUID())
        
        XCTAssertNil(foundRoom)
    }
    
    func testFindTrainingRoomByName_Success() async throws {
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        
        let foundRoom = try await sut.find(name: room.name)
        
        XCTAssertNotNil(foundRoom)
        XCTAssertEqual(foundRoom?.id, room.id)
        XCTAssertEqual(foundRoom?.capacity, room.capacity)
    }
    
    func testFindTrainingRoomByName_NotFound() async throws {
        let foundRoom = try await sut.find(name: "trainingRoomName")
        
        XCTAssertNil(foundRoom)
    }
}
