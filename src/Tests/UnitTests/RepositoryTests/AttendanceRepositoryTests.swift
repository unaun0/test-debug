//
//  AttendanceRepositoryTests.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 08.09.2025.
//

import Fluent
import Vapor
import XCTest

@testable import DataAccess
@testable import Domain
@testable import TestSupport

final class AttendanceRepositoryFixture {
    var app: Application!

    init() {}

    func setUp() async throws {
        app = try await Application.make(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.migrations.add(CreateAttendanceTable())
        
        try await app.autoMigrate()
    }

    func shutdown() async throws {
        try await app.asyncShutdown()
        app = nil
    }
}

final class AttendanceRepositoryTests: XCTestCase {
    var sut: AttendanceRepository!
    var fixture: AttendanceRepositoryFixture!
    
    override func setUp() async throws {
        try await super.setUp()
        fixture = AttendanceRepositoryFixture()
        try await fixture.setUp()
        sut = AttendanceRepository(db: fixture.app.db)
    }
    
    override func tearDown() async throws {
        sut = nil
        try await fixture.shutdown()
        fixture = nil
        try await super.tearDown()
    }
    
    // MARK: - delete

    func testDeleteAttendance_Success() async throws {
        let attendance = AttendanceBuilder().build()
        try await sut.create(attendance)

        try await sut.delete(id: attendance.id)

        let fetched = try await sut.find(id: attendance.id)
        XCTAssertNil(fetched)
    }

    func testDeleteAttendance_NotFound() async throws {
        let attendance = AttendanceBuilder().build()
        do {
            try await sut.delete(id: attendance.id)
            XCTFail("Expected AttendanceRepositoryError.attendanceNotFound to be thrown")
        } catch let error as AttendanceRepositoryError {
            XCTAssertEqual(error, .attendanceNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // MARK: - update

    func testUpdateAttendance_Success() async throws {
        let attendance = AttendanceBuilder().build()
        try await sut.create(attendance)
        let updatedAttendance = AttendanceBuilder()
            .withId(attendance.id)
            .withMembershipId(UUID())
            .withStatus(AttendanceStatus.absent)
            .withTrainingId(UUID())
            .build()

        try await sut.update(updatedAttendance)

        let fetched = try await sut.find(id: updatedAttendance.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, updatedAttendance.id)
        XCTAssertEqual(fetched?.membershipId, updatedAttendance.membershipId)
        XCTAssertEqual(fetched?.trainingId, updatedAttendance.trainingId)
        XCTAssertEqual(fetched?.status, updatedAttendance.status)
    }

    func testUpdateAttendance_NotFound() async throws {
        let attendance = AttendanceBuilder().build()

        do {
            try await sut.update(attendance)
            XCTFail("Expected UserError.userNotFound to be thrown")
            XCTFail("Expected AttendanceRepositoryError.attendanceNotFound to be thrown")
        } catch let error as AttendanceRepositoryError {
            XCTAssertEqual(error, .attendanceNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
