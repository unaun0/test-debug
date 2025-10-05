//
//  TrainingRoomServiceTests:.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor
import XCTest

@testable import TestSupport
@testable import Domain

final class TrainingRoomServiceTests: XCTestCase {
    var sut: TrainingRoomService!
    var repoMock: ITrainingRoomRepositoryMock!

    override func setUp() {
        super.setUp()
        repoMock = ITrainingRoomRepositoryMock()
        sut = TrainingRoomService(repository: repoMock)
    }

    override func tearDown() {
        sut = nil
        repoMock = nil
        super.tearDown()
    }

    // MARK: - create

    func testCreateRoom_Success() async throws {
        let dto = TrainingRoomCreateDTOBuilder().build()
        repoMock.findNameHandler = { _ in nil }

        let room = try await sut.create(dto)

        XCTAssertNotNil(room)
        XCTAssertEqual(room?.name, dto.name)
        XCTAssertEqual(room?.capacity, dto.capacity)
        XCTAssertEqual(repoMock.findNameCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 1)
    }

    func testCreateRoom_NameAlreadyExists() async throws {
        let dto = TrainingRoomCreateDTOBuilder().build()
        repoMock.findNameHandler = { input in
            return TrainingRoomBuilder().withName(input).build()
        }

        do {
            _ = try await sut.create(dto)
            XCTFail("Expected TrainingRoomError.nameAlreadyExists to be thrown")
        } catch let error as TrainingRoomError {
            XCTAssertEqual(error, .nameAlreadyExists)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
        XCTAssertEqual(repoMock.findNameCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 0)
    }

    // MARK: - update

    func testUpdateRoom_Success() async throws {
        let existingRoom = TrainingRoomBuilder().build()
        let updateDTO = TrainingRoomUpdateDTOBuilder()
            .withName("Зал №1")
            .withCapacity(50)
            .build()
        repoMock.findHandler = { id in
            return id == existingRoom.id ? existingRoom : nil
        }
        repoMock.findNameHandler = { _ in nil }

        let updated = try await sut.update(
            id: existingRoom.id,
            with: updateDTO
        )

        XCTAssertNotNil(updated)
        XCTAssertEqual(updated?.name, updateDTO.name)
        XCTAssertEqual(updated?.capacity, updateDTO.capacity)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.findNameCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 1)
    }

    func testUpdateRoom_NotFound() async {
        let updateDTO = TrainingRoomUpdateDTOBuilder().build()
        repoMock.findHandler = { _ in nil }

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
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    func testUpdateRoom_NameAlreadyExists() async throws {
        let existingRoom = TrainingRoomBuilder().build()
        let updateDTO = TrainingRoomUpdateDTOBuilder()
            .withName("Тест")
            .build()
        repoMock.findHandler = { _ in existingRoom }
        repoMock.findNameHandler = { _ in
            TrainingRoomBuilder().withName("Тест").build()
        }

        do {
            _ = try await sut.update(id: existingRoom.id, with: updateDTO)
            XCTFail("Expected TrainingRoomError.nameAlreadyExists to be thrown")
        } catch let error as TrainingRoomError {
            XCTAssertEqual(error, .nameAlreadyExists)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.findNameCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    // MARK: - delete

    func testDeleteRoom_Success() async throws {
        let id = UUID()
        repoMock.findHandler = { input in
            return input == id ? TrainingRoomBuilder().withId(id).build() : nil
        }

        try await sut.delete(id: id)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 1)
    }

    func testDeleteRoom_NotFound() async throws {
        let id = UUID()
        repoMock.findHandler = { _ in nil }

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
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 0)
    }
}
