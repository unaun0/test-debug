//
//  TrainingRoomITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 28.09.2025.
//

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import DataAccess
@testable import TestSupport
@testable import Domain

final class TrainingRoomServiceITCase: XCTestCase {
    var fixture: TestAppFixture!
    var repo: ITrainingRoomRepository!
    var sut: TrainingRoomService!

    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        repo = TrainingRoomRepository(db: fixture.db)
        sut = TrainingRoomService(repository: repo)
        
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

    // MARK: - create

    func testCreateRoom_Success() async throws {
        let dto = TrainingRoomCreateDTOBuilder().build()

        let room = try await sut.create(dto)

        XCTAssertNotNil(room)
        XCTAssertEqual(room?.name, dto.name)
        XCTAssertEqual(room?.capacity, dto.capacity)
    }

    func testCreateRoom_NameAlreadyExists() async throws {
        let name = "TrainingRoom Name"
        let tr = TrainingRoomBuilder()
            .withName(name)
            .build()
        try await TrainingRoomDBDTO(from: tr).create(on: fixture.db)
        let dto = TrainingRoomCreateDTOBuilder()
            .withName(name)
            .build()
       
        do {
            _ = try await sut.create(dto)
            XCTFail("Expected TrainingRoomError.nameAlreadyExists to be thrown")
        } catch let error as TrainingRoomError {
            XCTAssertEqual(error, .nameAlreadyExists)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - update

    func testUpdateRoom_Success() async throws {
        let existingRoom = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: existingRoom).create(on: fixture.db)
        let updateDTO = TrainingRoomUpdateDTOBuilder()
            .withName("Зал №1")
            .withCapacity(50)
            .build()
        
        let updated = try await sut.update(
            id: existingRoom.id,
            with: updateDTO
        )

        XCTAssertNotNil(updated)
        XCTAssertEqual(updated?.name, updateDTO.name)
        XCTAssertEqual(updated?.capacity, updateDTO.capacity)
    }

    func testUpdateRoom_NotFound() async {
        let updateDTO = TrainingRoomUpdateDTOBuilder().build()

        do {
            _ = try await sut.update(id: UUID(), with: updateDTO)
            XCTFail(
                "Expected TrainingRoomError.trainingRoomNotFound to be thrown"
            )
        } catch let error as TrainingRoomError {
            XCTAssertEqual(error, .trainingRoomNotFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testUpdateRoom_NameAlreadyExists() async throws {
        let existingRoom = TrainingRoomBuilder()
            .withName("Зал №1")
            .build()
        try await TrainingRoomDBDTO(from: existingRoom).create(on: fixture.db)
        let updateDTO = TrainingRoomUpdateDTOBuilder()
            .withName("Зал №1")
            .withCapacity(50)
            .build()
        
        do {
            _ = try await sut.update(id: existingRoom.id, with: updateDTO)
            XCTFail("Expected TrainingRoomError.nameAlreadyExists to be thrown")
        } catch let error as TrainingRoomError {
            XCTAssertEqual(error, .nameAlreadyExists)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - delete

    func testDeleteRoom_Success() async throws {
        let existingRoom = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: existingRoom).create(on: fixture.db)
        
        try await sut.delete(id: existingRoom.id)
        
        let deletedRoom = try await MembershipTypeDBDTO.query(
            on: fixture.db
        ).filter(\.$id == existingRoom.id).first()
        XCTAssertNil(deletedRoom)
    }

    func testDeleteRoom_NotFound() async throws {
        let id = UUID()
       
        do {
            try await sut.delete(id: id)
            XCTFail(
                "Expected TrainingRoomError.trainingRoomNotFound to be thrown"
            )
        } catch let error as TrainingRoomError {
            XCTAssertEqual(error, .trainingRoomNotFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
