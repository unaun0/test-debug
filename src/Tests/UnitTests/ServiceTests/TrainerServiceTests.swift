//
//  TrainerServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor
import XCTest

@testable import TestSupport
@testable import Domain

final class TrainerServiceTests: XCTestCase {
    private var repoMock: ITrainerRepositoryMock!
    private var sut: TrainerService!

    override func setUp() {
        super.setUp()
        repoMock = ITrainerRepositoryMock()
        sut = TrainerService(repository: repoMock)
    }

    override func tearDown() {
        repoMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - create

    func testCreateTrainer_Success() async throws {
        let dto = TrainerCreateDTOBuilder().build()
        repoMock.findUserIdHandler = { _ in nil }

        let trainer = try await sut.create(dto)

        XCTAssertEqual(repoMock.findUserIdCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 1)
        XCTAssertNotNil(trainer)
        XCTAssertEqual(trainer?.userId, dto.userId)
        XCTAssertEqual(trainer?.description, dto.description)
    }

    func testCreateTrainer_UserAlreadyHasTrainer() async throws {
        let dto = TrainerCreateDTOBuilder().build()
        repoMock.findUserIdHandler = { _ in
            TrainerBuilder()
                .withUserId(dto.userId)
                .build()
        }

        do {
            _ = try await sut.create(dto)
            XCTFail("Expected TrainerError.userAlreadyHasTrainer")
        } catch let error as TrainerError {
            XCTAssertEqual(error, .userAlreadyHasTrainer)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findUserIdCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 0)
    }

    // MARK: - update

    func testUpdateTrainer_Success() async throws {
        let trainer = TrainerBuilder().build()
        let dto = TrainerUpdateDTOBuilder()
            .withDescription("Updated description")
            .withUserId(UUID())
            .build()
        repoMock.findHandler = { _ in trainer }
        repoMock.findUserIdHandler = { _ in nil }

        let result = try await sut.update(id: trainer.id, with: dto)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 1)
        XCTAssertEqual(result?.id, trainer.id)
        XCTAssertEqual(result?.description, dto.description)
        XCTAssertEqual(result?.userId, dto.userId)
    }

    func testUpdateTrainer_NotFound() async throws {
        let dto = TrainerUpdateDTOBuilder().build()
        repoMock.findHandler = { _ in nil }

        do {
            _ = try await sut.update(id: UUID(), with: dto)
            XCTFail("Expected TrainerError.trainerNotFound")
        } catch let error as TrainerError {
            XCTAssertEqual(error, .trainerNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    func testUpdateTrainer_UserAlreadyHasTrainer() async throws {
        let trainer = TrainerBuilder().build()
        let dto = TrainerUpdateDTOBuilder()
            .withUserId(UUID())
            .build()
        repoMock.findHandler = { _ in trainer }
        repoMock.findUserIdHandler = { _ in TrainerBuilder().build() }

        do {
            _ = try await sut.update(id: trainer.id, with: dto)
            XCTFail("Expected TrainerError.userAlreadyHasTrainer")
        } catch let error as TrainerError {
            XCTAssertEqual(error, .userAlreadyHasTrainer)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.findUserIdCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    // MARK: - delete
    
    func testDeleteTrainer_Success() async throws {
        let trainer = TrainerBuilder().build()
        repoMock.findHandler = { _ in trainer }
        

        try await sut.delete(id: trainer.id)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 1)
    }
    
    func testDeleteTrainer_NotFound() async throws {
        let trainerId = UUID()
        repoMock.findHandler = { _ in nil}

        do {
            try await sut.delete(id: trainerId)
            XCTFail("Expected TrainerError.trainerNotFound")
        } catch let error as TrainerError {
            XCTAssertEqual(error, .trainerNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 0)
    }
}
