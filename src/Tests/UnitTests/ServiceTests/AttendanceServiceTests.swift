//
//  AttendanceServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor
import XCTest

@testable import Domain
@testable import TestSupport

final class AttendanceServiceTests: XCTestCase {
    private var repoMock: IAttendanceRepositoryMock!
    private var sut: AttendanceService!

    override func setUp() {
        super.setUp()
        repoMock = IAttendanceRepositoryMock()
        sut = AttendanceService(repository: repoMock)
    }

    override func tearDown() {
        sut = nil
        repoMock = nil
        super.tearDown()
    }

    // MARK: - create

    func testCreate_Success() async throws {
        let dto = AttendanceCreateDTOBuilder().build()
        repoMock.findTrainingIdHandler = { _ in [] }

        let result = try await sut.create(dto)

        XCTAssertEqual(repoMock.findTrainingIdCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 1)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.membershipId, dto.membershipId)
        XCTAssertEqual(result?.trainingId, dto.trainingId)
        XCTAssertEqual(result?.status, dto.status)
    }

    func testCreate_DuplicateExists() async throws {
        let dto = AttendanceCreateDTOBuilder().build()
        let existing = AttendanceBuilder()
            .withMembershipId(dto.membershipId)
            .withTrainingId(dto.trainingId)
            .build()
        repoMock.findTrainingIdHandler = { _ in [existing] }

        do {
            _ = try await self.sut.create(dto)
            XCTFail("Expected TrainingError.invalidMembershipTrainingUnique")
        } catch let error as AttendanceError {
            XCTAssertEqual(error, .invalidMembershipTrainingUnique)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findTrainingIdCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 0)
    }

    // MARK: - update

    func testUpdate_Success() async throws {
        let attendance = AttendanceBuilder().build()
        let dto = AttendanceUpdateDTOBuilder()
            .withStatus(.attended)
            .withTrainingId(UUID())
            .withMembershipId(UUID())
            .build()
        repoMock.findHandler = { _ in attendance }
        repoMock.findTrainingIdHandler = { _ in [] }

        let result = try await sut.update(
            id: attendance.id,
            with: dto
        )

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 1)
        XCTAssertEqual(result?.status, dto.status)
        XCTAssertEqual(result?.trainingId, dto.trainingId)
        XCTAssertEqual(result?.membershipId, dto.membershipId)
    }

    func testUpdate_NotFound() async throws {
        repoMock.findHandler = { _ in nil }
        let dto = AttendanceUpdateDTOBuilder().build()

        do {
            _ = try await self.sut.update(id: UUID(), with: dto)
            XCTFail("Expected TrainingError.attendanceNotFound")
        } catch let error as AttendanceError {
            XCTAssertEqual(error, .attendanceNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }
    
    func testUpdate_InvalidMembershipTrainingUnique() async throws {
        let attendance = AttendanceBuilder().build()
        let dto = AttendanceUpdateDTOBuilder()
            .withStatus(.attended)
            .withTrainingId(UUID())
            .withMembershipId(UUID())
            .build()
        repoMock.findHandler = { _ in attendance }
        repoMock.findTrainingIdHandler = { _ in
            [
                AttendanceBuilder()
                    .withTrainingId(dto.trainingId!)
                    .withMembershipId(dto.membershipId!)
                    .build()
            ]
        }

        do {
            _ = try await self.sut.update(id: UUID(), with: dto)
            XCTFail("Expected TrainingError.invalidMembershipTrainingUnique")
        } catch let error as AttendanceError {
            XCTAssertEqual(error, .invalidMembershipTrainingUnique)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    // MARK: - delete

    func testDelete_Success() async throws {
        let attendance = AttendanceBuilder().build()
        repoMock.findHandler = { _ in attendance }

        try await sut.delete(id: attendance.id)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 1)
    }

    func testDelete_Fails_WhenNotFound() async throws {
        let attendanceId = UUID()
        repoMock.findHandler = { _ in nil }

        do {
            try await self.sut.delete(id: attendanceId)
            XCTFail("Expected TrainingError.attendanceNotFound")
        } catch let error as AttendanceError {
            XCTAssertEqual(error, .attendanceNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 0)
    }
}
