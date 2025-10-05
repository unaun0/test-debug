//
//  UserServiceITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 28.09.2025.
//

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import TestSupport
@testable import Domain
@testable import DataAccess

final class UserServiceITCase: XCTestCase {
    var fixture: TestAppFixture!
    var repo: IUserRepository!
    var hasher: IHasherService!
    
    var sut: UserService!

    override func setUp() async throws {
        try await super.setUp()

        fixture = try await TestAppFixture()
        repo = UserRepository(db: fixture.db)
        hasher = BcryptHasherService()

        sut = UserService(
            userRepository: repo,
            passwordHasher: hasher
        )
        
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

    // MARK: - create

    func testCreateUser_Success() async throws {
        let userDTO = UserCreateDTOBuilder().build()

        let user = try await sut.create(userDTO)

        XCTAssertNotNil(user)
        XCTAssertTrue(try hasher.verify(userDTO.password, created: user!.password))
        XCTAssertEqual(user?.email, userDTO.email)
        XCTAssertEqual(user?.phoneNumber, userDTO.phoneNumber)
        XCTAssertEqual(user?.firstName, userDTO.firstName)
        XCTAssertEqual(user?.lastName, userDTO.lastName)
        XCTAssertEqual(user?.gender, userDTO.gender)
        XCTAssertEqual(user?.role, userDTO.role)
    }

    func testCreateUser_EmailAlreadyExists() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let anotherUserDTO = UserCreateDTOBuilder()
            .withEmail(user.email)
            .withPhoneNumber("+000111000111")
            .build()
        do {
            _ = try await sut.create(anotherUserDTO)
            XCTFail("Expected UserError.emailAlreadyExists to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .emailAlreadyExists)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    func testCreateUser_PhoneNumberAlreadyExists() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let anotherUserDTO = UserCreateDTOBuilder()
            .withEmail("e@e.e")
            .withPhoneNumber(user.phoneNumber)
            .build()

        do {
            _ = try await sut.create(anotherUserDTO)
            XCTFail("Expected UserError.phoneNumberAlreadyExists to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .phoneNumberAlreadyExists)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // MARK: - delete

    func testDeleteUser_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)

        try await sut.delete(id: user.id)
        
        let deletedUser = try await UserDBDTO.query(
            on: fixture.db
        ).filter(\.$id == user.id).first()
        XCTAssertNil(deletedUser)
    }

    func testDeleteUser_UserNotFound() async throws {
        let userId = UUID()

        do {
            try await sut.delete(id: userId)
            XCTFail("Expected UserError.userNotFound to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .userNotFound)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }

    // MARK: - update

    func testUpdateUser_Success() async throws {
        let existingUser = UserBuilder().build()
        try await UserDBDTO(from: existingUser).create(on: fixture.db)
        let updateData = UserUpdateDTOBuilder()
            .withFirstName("Test")
            .withLastName("Test")
            .withBirthDate("2003-12-27 00:00:00")
            .withRole(UserRoleName.trainer)
            .withEmail("123a@wxample.com")
            .withPhoneNumber("+1234567890")
            .withGender(UserGender.female)
            .withPassword("paspaspassword1234")
            .build()
        
        let updatedUser = try await sut.update(
            id: existingUser.id,
            with: updateData
        )

        XCTAssertNotNil(updatedUser)
        XCTAssertEqual(updatedUser?.firstName, updateData.firstName)
        XCTAssertEqual(updatedUser?.lastName, updateData.lastName)
        XCTAssertEqual(updatedUser?.role, updateData.role)
        XCTAssertEqual(updatedUser?.email, updateData.email)
        XCTAssertEqual(updatedUser?.phoneNumber, updateData.phoneNumber)
        XCTAssertEqual(updatedUser?.gender, updateData.gender)
        XCTAssertEqual(updatedUser?.email, updateData.email)
        XCTAssertTrue(try hasher.verify(updateData.password!, created: updatedUser!.password))
    }

    func testUpdateUser_UserNotFound() async {
        let updateData = UserUpdateDTOBuilder().build()

        do {
            _ = try await sut.update(id: UUID(), with: updateData)
            XCTFail("Expected UserError.userNotFound to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .userNotFound)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }

    func testUpdateUser_EmailAlreadyExists() async throws {
        let existingUser = UserBuilder().build()
        try await UserDBDTO(from: existingUser).create(on: fixture.db)
        let anotherExistingUser = UserBuilder()
            .withEmail("email@email.email")
            .withPhoneNumber("+100010001000")
            .build()
        try await UserDBDTO(from: anotherExistingUser).create(on: fixture.db)
        let updateData = UserUpdateDTOBuilder()
            .withEmail(existingUser.email)
            .build()
        
        do {
            _ = try await sut.update(id: anotherExistingUser.id, with: updateData)
            XCTFail("Expected UserError.emailAlreadyExists to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .emailAlreadyExists)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }

    func testUpdateUser_PhoneNumberAlreadyExists() async throws {
        let existingUser = UserBuilder().build()
        try await UserDBDTO(from: existingUser).create(on: fixture.db)
        let anotherExistingUser = UserBuilder()
            .withEmail("email@email.email")
            .withPhoneNumber("+100010001000")
            .build()
        try await UserDBDTO(from: anotherExistingUser).create(on: fixture.db)
        let updateData = UserUpdateDTOBuilder()
            .withPhoneNumber(existingUser.phoneNumber)
            .build()

        do {
            _ = try await sut.update(id: anotherExistingUser.id, with: updateData)
            XCTFail("Expected UserError.phoneNumberAlreadyExists to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .phoneNumberAlreadyExists)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }
}
