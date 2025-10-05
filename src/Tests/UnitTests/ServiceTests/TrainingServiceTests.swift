//
//  TrainingServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor
import XCTest

@testable import TestSupport
@testable import Domain

final class TrainingServiceTests: XCTestCase {
    var sut: TrainingService!
    var repoMock: ITrainingRepositoryMock!

    override func setUp() {
        super.setUp()
        repoMock = ITrainingRepositoryMock()
        sut = TrainingService(repository: repoMock)
    }

    override func tearDown() {
        sut = nil
        repoMock = nil
        super.tearDown()
    }

    // MARK: - create

    func testCreateTraining_Success() async throws {
        let dto = TrainingCreateDTOBuilder().build()
        
        let training = try await sut.create(dto)

        XCTAssertEqual(repoMock.createCallCount, 1)
        XCTAssertNotNil(training)
        XCTAssertEqual(training?.roomId, dto.roomId)
        XCTAssertEqual(training?.trainerId, dto.trainerId)
        XCTAssertEqual(
            training?.date,
            dto.date?.toDate(
                format: ValidationRegex.DateFormat.format
            )
        )
    }
    
    func testCreateTraining_InvalidDate_Throws() async {
        let dto = TrainingCreateDTOBuilder()
            .withDate("invalid date")
            .build()

        do {
            _ = try await sut.create(dto)
            XCTFail("Expected TrainingError.invalidDate to be thrown")
        } catch let error as TrainingError {
            XCTAssertEqual(error, .invalidDate)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(repoMock.createCallCount, 0)
    }

    // MARK: - update

    func testUpdateTraining_Success() async throws {
        let existingTraining = TrainingBuilder().build()
        let dto = TrainingUpdateDTOBuilder()
            .withDate("2030-09-07 12:00:00")
            .withRoomId(UUID())
            .withTrainerId(UUID())
            .build()
        repoMock.findHandler = { _ in existingTraining }

        let training = try await sut.update(
            id: existingTraining.id,
            with: dto
        )

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 1)
        XCTAssertNotNil(training)
        XCTAssertEqual(training?.id, existingTraining.id)
        XCTAssertEqual(training?.roomId, dto.roomId)
        XCTAssertEqual(training?.trainerId, dto.trainerId)
        XCTAssertEqual(
            training?.date,
            dto.date?.toDate(
                format: ValidationRegex.DateFormat.format
            )!
        )
    }

    func testUpdateTraining_NotFound() async {
        let dto = TrainingUpdateDTOBuilder().build()
        repoMock.findHandler = { _ in nil }

        do {
            _ = try await sut.update(id: UUID(), with: dto)
            XCTFail("Expected TrainingError.trainerNotFound")
        } catch let error as TrainingError {
            XCTAssertEqual(error, .trainerNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    func testUpdateTraining_InvalidDate() async throws {
        let existingTraining = TrainingBuilder().build()
        let dto = TrainingUpdateDTOBuilder()
            .withDate("invalid date")
            .withRoomId(UUID())
            .withTrainerId(UUID())
            .build()
        repoMock.findHandler = { _ in existingTraining }

        do {
            _ = try await sut.update(id: existingTraining.id, with: dto)
            XCTFail("Expected TrainingError.invalidDate")
        } catch let error as TrainingError {
            XCTAssertEqual(error, .invalidDate)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    // MARK: - delete

    func testDeleteTraining_Success() async throws {
        let trainingId = UUID()
        repoMock.findHandler = { _ in Training(
            id: trainingId,
            date: Date(),
            roomId: UUID(),
            trainerId: UUID()
        )}

        try await sut.delete(id: trainingId)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 1)
    }

    func testDeleteTraining_NotFound() async throws {
        let trainingId = UUID()
        repoMock.findHandler = { _ in nil }

        do {
            try await sut.delete(id: trainingId)
            XCTFail("Expected TrainingError.trainingNotFound")
        } catch let error as TrainingError {
            XCTAssertEqual(error, .trainingNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.deleteCallCount, 0)
    }
}
