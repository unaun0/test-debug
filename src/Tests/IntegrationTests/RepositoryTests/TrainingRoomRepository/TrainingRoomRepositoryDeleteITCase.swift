//
//  TrainingRoomRepositoryDeleteITCase.swift
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

final class TrainingRoomRepositoryDeleteITCase: XCTestCase {
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
    
    func testDeleteTrainingRoom_Success() async throws {
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        
        try await sut.delete(id: room.id)
        
        let deletedRoom = try await MembershipTypeDBDTO.query(
            on: fixture.db
        ).filter(\.$id == room.id).first()
        XCTAssertNil(deletedRoom)
    }
    
    func testDeleteTrainingRoom_NotFound() async throws {
        do {
            try await sut.delete(id: UUID())
            XCTFail("Expected TrainingRoomRepositoryError but none was thrown")
        } catch let error as TrainingRoomRepositoryError {
            XCTAssertEqual(TrainingRoomRepositoryError.trainingRoomNotFound, error)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
