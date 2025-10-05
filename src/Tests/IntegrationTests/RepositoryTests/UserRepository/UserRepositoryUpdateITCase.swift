//
//  UserRepositoryUpdateITCase.swift
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

final class UserRepositoryUpdateITCase: XCTestCase {
    var fixture: TestAppFixture!
    var sut: UserRepository!

    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        sut = UserRepository(db: fixture.db)
        try await self.clearDatabase()
    }

    override func tearDown() async throws {
        try await self.clearDatabase()
        try await fixture.shutdown()
        
        try await super.tearDown()
    }
    
    private func clearDatabase() async throws {
        try await UserDBDTO.query(on: fixture.db).delete()
    }

    func testUpdateUser_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let userUpdateData = UserBuilder()
            .withId(user.id)
            .withEmail("testtest@example.com")
            .withPhoneNumber("+0987654321")
            .withPassword("Password1234567890")
            .withFirstName("Name")
            .withLastName("Name")
            .withGender(UserGender.female)
            .withRole(UserRoleName.admin)
            .withAge(years: 64)
            .build()
        
        try await sut.update(userUpdateData)
            
        let createdUser = try await UserDBDTO.query(
            on: fixture.db
        ).filter(\.$id == user.id).first()
        XCTAssertNotNil(createdUser)
        XCTAssertEqual(createdUser?.email, userUpdateData.email)
        XCTAssertEqual(createdUser?.phoneNumber, userUpdateData.phoneNumber)
        XCTAssertEqual(createdUser?.firstName, userUpdateData.firstName)
        XCTAssertEqual(createdUser?.lastName, userUpdateData.lastName)
        XCTAssertEqual(createdUser?.password, userUpdateData.password)
        XCTAssertEqual(createdUser?.role, userUpdateData.role.rawValue)
        XCTAssertEqual(createdUser?.gender, userUpdateData.gender.rawValue)
    }
    
    func testUpdateUser_DuplicateEmail() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let anotherUser = UserBuilder()
            .withEmail("testtest@example.com")
            .withPhoneNumber("+0987654320")
            .build()
        try await UserDBDTO(from: anotherUser).create(on: fixture.db)
        let userUpdateData = UserBuilder()
            .withId(user.id)
            .withEmail("testtest@example.com")
            .build()
        
        do {
            try await sut.update(userUpdateData)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUpdateUser_DuplicatePhone() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let anotherUser = UserBuilder()
            .withEmail("testtest@example.com")
            .withPhoneNumber("+0987654320")
            .build()
        try await UserDBDTO(from: anotherUser).create(on: fixture.db)
        let userUpdateData = UserBuilder()
            .withId(user.id)
            .withPhoneNumber("+0987654320")
            .build()
        
        do {
            try await sut.update(userUpdateData)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUpdateUser_UserNotFound() async throws {
        let user = UserBuilder().build()
        
        do {
            try await sut.update(user)
            XCTFail("Expected UserRepositoryError but none was thrown")
        } catch let error as UserRepositoryError {
            XCTAssertEqual(UserRepositoryError.userNotFound, error)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
