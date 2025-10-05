//
//  UserRepositoryCreateITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 24.09.2025.
//

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import DataAccess
@testable import TestSupport

final class UserRepositoryCreateITCase: XCTestCase {
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

    func testCreateUser_Success() async throws {
        let user = UserBuilder().build()
            
        try await sut.create(user)
            
        let createdUser = try await UserDBDTO.query(
            on: fixture.db
        ).filter(\.$id == user.id).first()
        XCTAssertNotNil(createdUser)
        XCTAssertEqual(createdUser?.email, user.email)
        XCTAssertEqual(createdUser?.phoneNumber, user.phoneNumber)
        XCTAssertEqual(createdUser?.firstName, user.firstName)
        XCTAssertEqual(createdUser?.lastName, user.lastName)
        XCTAssertEqual(createdUser?.password, user.password)
        XCTAssertEqual(createdUser?.role, user.role.rawValue)
        XCTAssertEqual(createdUser?.gender, user.gender.rawValue)
    }
    
    func testCreateUser_DuplicatePhone() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let userDuplicatePhone = UserBuilder()
            .withId(UUID())
            .withEmail("testtest@example.com")
            .withPhoneNumber(user.phoneNumber)
            .build()

        do {
            try await sut.create(userDuplicatePhone)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCreateUser_DuplicateEmail() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let userDuplicatePhone = UserBuilder()
            .withId(UUID())
            .withEmail(user.email)
            .withPhoneNumber("+0987654321")
            .build()

        do {
            try await sut.create(userDuplicatePhone)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCreateUser_DuplicateId() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let userDuplicateId = UserBuilder()
            .withId(user.id)
            .withEmail("email@email.email")
            .withPhoneNumber("+0987654321")
            .build()

        do {
            try await sut.create(userDuplicateId)
            XCTFail("Expected PSQLError but none was thrown")
        } catch let error as PSQLError {
            XCTAssertEqual(error.code, PSQLError.Code.server)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
