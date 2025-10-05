//
//  MembershipTypeRepositoryUpdateITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 24.09.2025.
// 

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import Domain
@testable import DataAccess
@testable import TestSupport

final class AttendanceRepositoryUpdateITCase: XCTestCase {
    var fixture: TestAppFixture!
    var sut: AttendanceRepository!

    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        sut = AttendanceRepository(db: fixture.db)
        
        try await self.clearDatabase()
    }

    override func tearDown() async throws {
        try await self.clearDatabase()
        try await fixture.shutdown()
        
        try await super.tearDown()
    }
    
    private func clearDatabase() async throws {
        try await AttendanceDBDTO.query(on: fixture.db).delete()
        try await TrainingDBDTO.query(on: fixture.db).delete()
        try await TrainingRoomDBDTO.query(on: fixture.db).delete()
        try await TrainerDBDTO.query(on: fixture.db).delete()
        try await MembershipDBDTO.query(on: fixture.db).delete()
        try await MembershipTypeDBDTO.query(on: fixture.db).delete()
        try await UserDBDTO.query(on: fixture.db).delete()
    }
    
    func testUpdateAttendance_Success() async throws {
        let userClient = UserBuilder().build()
        try await UserDBDTO(from: userClient).create(on: fixture.db)
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let m = MembershipBuilder()
            .withUserId(userClient.id)
            .withMembershipTypeId(mt.id)
            .build()
        try await MembershipDBDTO(from: m).create(on: fixture.db)
        let userTrainer = UserBuilder()
            .withEmail("e@e.e")
            .withPhoneNumber("+1234567890")
            .withRole(UserRoleName.trainer)
            .build()
        try await UserDBDTO(from: userTrainer).create(on: fixture.db)
        let trainer = TrainerBuilder()
            .withUserId(userTrainer.id)
            .build()
        try await TrainerDBDTO(from: trainer).create(on: fixture.db)
        let room = TrainingRoomBuilder().build()
        try await TrainingRoomDBDTO(from: room).create(on: fixture.db)
        let training = TrainingBuilder()
            .withRoomId(room.id)
            .withTrainerId(trainer.id)
            .build()
        try await TrainingDBDTO(from: training).create(on: fixture.db)
        let attendance = AttendanceBuilder()
            .withTrainingId(training.id)
            .withMembershipId(m.id)
            .build()
        try await AttendanceDBDTO(from: attendance).create(on: fixture.db)
        let attendanceUpdateData = AttendanceBuilder()
            .withId(attendance.id)
            .withTrainingId(training.id)
            .withMembershipId(m.id)
            .withStatus(AttendanceStatus.attended)
            .build()
        
        try await sut.update(attendanceUpdateData)
        
        let updatedAttendance = try await AttendanceDBDTO.query(
            on: fixture.db
        ).filter(\.$id == attendance.id).first()
        XCTAssertNotNil(updatedAttendance)
        XCTAssertEqual(updatedAttendance?.membershipId, attendanceUpdateData.membershipId)
        XCTAssertEqual(updatedAttendance?.trainingId, attendanceUpdateData.trainingId)
        XCTAssertEqual(updatedAttendance?.status, attendanceUpdateData.status.rawValue)
    }

    func testUpdateAttendance_NotFound() async throws {
        let a = AttendanceBuilder().build()
        
        do {
            try await sut.update(a)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as AttendanceRepositoryError {
            XCTAssertEqual(error, AttendanceRepositoryError.attendanceNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
