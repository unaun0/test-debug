//
//  AttendanceServiceITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 29.09.2025.
//

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import Domain
@testable import DataAccess
@testable import TestSupport

final class AttendanceServiceITCase: XCTestCase {
    var fixture: TestAppFixture!
    var repo: IAttendanceRepository!
    var sut: AttendanceService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        repo = AttendanceRepository(db: fixture.db)
        sut = AttendanceService(repository: repo)
        
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
    
    // MARK: - create

    func testCreate_Success() async throws {
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
        let dto = AttendanceCreateDTOBuilder()
            .withTrainingId(training.id)
            .withMembershipId(m.id)
            .build()

        let result = try await sut.create(dto)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.membershipId, dto.membershipId)
        XCTAssertEqual(result?.trainingId, dto.trainingId)
        XCTAssertEqual(result?.status, dto.status)
    }

    func testCreate_DuplicateExists() async throws {
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
        let dto = AttendanceCreateDTOBuilder()
            .withTrainingId(training.id)
            .withMembershipId(m.id)
            .build()
        
        do {
            _ = try await self.sut.create(dto)
            XCTFail("Expected TrainingError.invalidMembershipTrainingUnique")
        } catch let error as AttendanceError {
            XCTAssertEqual(error, .invalidMembershipTrainingUnique)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - update

    func testUpdate_Success() async throws {
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
        let dto = AttendanceUpdateDTOBuilder()
            .withStatus(.attended)
            .build()

        let result = try await sut.update(
            id: attendance.id,
            with: dto
        )

        XCTAssertEqual(result?.status, dto.status)
        XCTAssertEqual(result?.trainingId, attendance.trainingId)
        XCTAssertEqual(result?.membershipId, attendance.membershipId)
    }

    func testUpdate_NotFound() async throws {
        let dto = AttendanceUpdateDTOBuilder().build()

        do {
            _ = try await self.sut.update(id: UUID(), with: dto)
            XCTFail("Expected TrainingError.attendanceNotFound")
        } catch let error as AttendanceError {
            XCTAssertEqual(error, .attendanceNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - delete

    func testDelete_Success() async throws {
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

        try await sut.delete(id: attendance.id)
        
        let deletedAttendance = try await MembershipDBDTO.query(
            on: fixture.db
        ).filter(\.$id == attendance.id).first()
        XCTAssertNil(deletedAttendance)
    }

    func testDelete_Fails_WhenNotFound() async throws {
        let attendanceId = UUID()

        do {
            try await self.sut.delete(id: attendanceId)
            XCTFail("Expected TrainingError.attendanceNotFound")
        } catch let error as AttendanceError {
            XCTAssertEqual(error, .attendanceNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
