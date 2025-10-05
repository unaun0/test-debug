//
//  DemoE2ETests.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 29.09.2025.
//

import Fluent
import FluentPostgresDriver
import Vapor
import VaporTesting
import XCTest

@testable import DataAccess
@testable import Domain
@testable import TestSupport

final class DemoE2ETests: XCTestCase {
    var fixture: FullAppTestFixture!
    var demoData: DemoDataFixture!

    override func setUp() async throws {
        try await super.setUp()

        fixture = try await FullAppTestFixture()
        try await DemoDataFixture.clearDatabase(on: fixture.app.db)
        demoData = try await DemoDataFixture.prepare(on: fixture.app.db)
    }

    override func tearDown() async throws {
        try await DemoDataFixture.clearDatabase(on: fixture.app.db)
        try await fixture.shutdown()

        fixture = nil
        demoData = nil

        try await super.tearDown()
    }

    func test() async throws {
        var tokenValue: String? = nil
        var newUserUUID: UUID? = nil
        var newMembershipUUID: UUID? = nil
        var newAttendanceUUID: UUID? = nil

        // Авторизация админа в системе

        try await fixture.app.test(
            .POST,
            "/auth/login",
            beforeRequest: { req in
                try req.content.encode(
                    LoginDTO(
                        login: demoData.adminCredentials.email,
                        password: demoData.adminCredentials.password
                    )
                )
            },
            afterResponse: { res in
                XCTAssertEqual(res.status, .ok)

                tokenValue = try res.content.decode(TokenDTO.self).token
            }
        )

        // Регистрация нового пользователя-клиента админом

        try await fixture.app.test(
            .POST,
            "/admin/users",
            beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(
                    token: tokenValue!
                )
                try req.content.encode(demoData.newUserRegisterDTO)
            },
            afterResponse: { res in
                XCTAssertEqual(res.status, .ok)

                newUserUUID = try res.content.decode(UserAdminDTO.self).id
        
                let createdUser = try await UserDBDTO.query(
                    on: fixture.app.db
                ).filter(\.$id == newUserUUID!).first()
                XCTAssertNotNil(createdUser)
                XCTAssertEqual(createdUser?.id, newUserUUID)
                XCTAssertEqual(createdUser?.email, demoData.newUserRegisterDTO.email)
                XCTAssertEqual(createdUser?.phoneNumber, demoData.newUserRegisterDTO.phoneNumber)
                XCTAssertEqual(createdUser?.firstName, demoData.newUserRegisterDTO.firstName)
                XCTAssertEqual(createdUser?.lastName, demoData.newUserRegisterDTO.lastName)
                XCTAssertEqual(createdUser?.role, demoData.newUserRegisterDTO.role.rawValue)
                XCTAssertEqual(createdUser?.gender, demoData.newUserRegisterDTO.gender.rawValue)
            }
        )

        // Добавление абонемента созданному пользователю

        try await fixture.app.test(
            .POST,
            "admin/memberships",
            beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(
                    token: tokenValue!
                )
                try req.content.encode(
                    MembershipCreateDTO(
                        userId: newUserUUID!,
                        membershipTypeId: demoData.membershipTypeId
                    )
                )
            },
            afterResponse: { res in
                XCTAssertEqual(res.status, .created)

                newMembershipUUID = try res.content.decode(MembershipDTO.self).id
                
                let createdMembership = try await MembershipDBDTO.query(
                    on: fixture.app.db
                ).filter(\.$id == newMembershipUUID!).first()
                XCTAssertNotNil(createdMembership)
                XCTAssertEqual(createdMembership?.userId, newUserUUID!)
                XCTAssertEqual(createdMembership?.membershipTypeId, demoData.membershipTypeId)
            }
        )

        // Запись пользователя на тренировку по созданному абонементу

        try await fixture.app.test(
            .POST,
            "admin/attendances",
            beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(
                    token: tokenValue!
                )
                try req.content.encode(
                    AttendanceCreateDTO(
                        membershipId: newMembershipUUID!,
                        trainingId: demoData.trainingId,
                        status: .waiting
                    )
                )
            },
            afterResponse: { res in
                XCTAssertEqual(res.status, .created)
                
                newAttendanceUUID = try res.content.decode(AttendanceDTO.self).id
                
                let createdAttendance = try await AttendanceDBDTO.query(
                    on: fixture.app.db
                ).filter(\.$id == newAttendanceUUID!).first()
                XCTAssertNotNil(createdAttendance)
                XCTAssertEqual(createdAttendance?.id, newAttendanceUUID)
                XCTAssertEqual(createdAttendance?.status, AttendanceStatus.waiting.rawValue)
                XCTAssertEqual(createdAttendance?.trainingId, demoData.trainingId)
                XCTAssertEqual(createdAttendance?.membershipId, newMembershipUUID)
            }
        )
    }
}

struct DemoDataFixture {
    let adminCredentials: (email: String, password: String)
    let adminId: UUID
    let trainerId: UUID

    let membershipTypeId: UUID
    let trainingId: UUID

    let newUserRegisterDTO: UserCreateDTO

    static func prepare(on db: Database) async throws -> DemoDataFixture {
        let adminUserId = UUID()
        let adminEmail = "admin@example.com"
        let adminPassword = "Password1234!"

        let adminUser = UserBuilder()
            .withId(adminUserId)
            .withFirstName("Admin")
            .withLastName("Admin")
            .withEmail(adminEmail)
            .withPhoneNumber("+1234567890")
            .withRole(.admin)
            .withPassword(try BcryptHasherService().hash(adminPassword))
            .build()
        try await UserDBDTO(from: adminUser).create(on: db)

        let trainerUser = UserBuilder()
            .withFirstName("Trainer")
            .withLastName("Trainer")
            .withEmail("trainer@example.com")
            .withPhoneNumber("+1234567891")
            .withRole(.trainer)
            .withPassword(try BcryptHasherService().hash("Password1234"))
            .build()
        try await UserDBDTO(from: trainerUser).create(on: db)

        let trainerId = UUID()
        let trainer = TrainerBuilder()
            .withId(trainerId)
            .withUserId(trainerUser.id)
            .withDescription("Опытный тренер")
            .build()
        try await TrainerDBDTO(from: trainer).create(on: db)

        let membershipTypeId = UUID()
        let membershipType = MembershipTypeBuilder()
            .withId(membershipTypeId)
            .withDays(30)
            .withName("Абонемент 30 дней")
            .withPrice(1000.00)
            .withSessions(4)
            .build()
        try await MembershipTypeDBDTO(from: membershipType).create(on: db)

        let trainingRoom = TrainingRoomBuilder()
            .withName("Зал №1")
            .withCapacity(5)
            .build()
        try await TrainingRoomDBDTO(from: trainingRoom).create(on: db)

        let trainingId = UUID()
        let training = TrainingBuilder()
            .withId(trainingId)
            .withRoomId(trainingRoom.id)
            .withTrainerId(trainer.id)
            .withDate(
                Calendar.current.date(
                    bySettingHour: 14,
                    minute: 0,
                    second: 0,
                    of: Calendar.current.date(
                        byAdding: .day,
                        value: 1,
                        to: Date()
                    )!
                )!
            )
            .build()
        try await TrainingDBDTO(from: training).create(on: db)

        let newUserRegisterDTO = UserCreateDTOBuilder()
            .withEmail("ivanov@example.com")
            .withPhoneNumber("+1234567892")
            .withPassword("UserPass123!")
            .withFirstName("Иван")
            .withLastName("Иванов")
            .withBirthDate("2000-01-01 00:00:00")
            .withGender(.male)
            .withRole(.client)
            .build()

        return DemoDataFixture(
            adminCredentials: (email: adminEmail, password: adminPassword),
            adminId: adminUserId,
            trainerId: trainerId,
            membershipTypeId: membershipTypeId,
            trainingId: trainingId,
            newUserRegisterDTO: newUserRegisterDTO
        )
    }
}

extension DemoDataFixture {
    static func clearDatabase(on db: Database) async throws {
        try await db.transaction { transaction in
            try await AttendanceDBDTO.query(on: transaction).delete()
            try await MembershipDBDTO.query(on: transaction).delete()
            try await TrainingDBDTO.query(on: transaction).delete()
            try await TrainingRoomDBDTO.query(on: transaction).delete()
            try await MembershipTypeDBDTO.query(on: transaction).delete()
            try await TrainerDBDTO.query(on: transaction).delete()
            try await UserDBDTO.query(on: transaction).delete()
        }
    }
}
