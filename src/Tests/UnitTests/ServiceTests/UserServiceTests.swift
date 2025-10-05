//
//  UserServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor
import XCTest

@testable import TestSupport
@testable import Domain

final class UserServiceTests: XCTestCase {
    var sut: UserService!
    var repoMock: IUserRepositoryMock!
    var hasherMock: IHasherServiceMock!

    override func setUp() {
        super.setUp()

        repoMock = IUserRepositoryMock()
        hasherMock = IHasherServiceMock()
        sut = UserService(
            userRepository: repoMock,
            passwordHasher: hasherMock
        )
    }

    override func tearDown() {
        sut = nil
        repoMock = nil
        hasherMock = nil

        super.tearDown()
    }

    // MARK: - create

    func testCreateUser_Success() async throws {
        let userDTO = UserCreateDTOBuilder().build()

        let user = try await sut.create(userDTO)

        XCTAssertNotNil(user)
        XCTAssertEqual(user?.email, userDTO.email)
        XCTAssertEqual(user?.phoneNumber, userDTO.phoneNumber)
        XCTAssertEqual(user?.firstName, userDTO.firstName)
        XCTAssertEqual(user?.lastName, userDTO.lastName)
        XCTAssertEqual(user?.gender, userDTO.gender)
        XCTAssertEqual(user?.role, userDTO.role)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.findPhoneNumberCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 1)
        XCTAssertEqual(hasherMock.hashCallCount, 1)
    }

    func testCreateUser_EmailAlreadyExists() async throws {
        let userDTO = UserCreateDTOBuilder().build()
        repoMock.findHandler = { input in
            return input == userDTO.email
                ? UserBuilder().withEmail(
                    userDTO.email
                ).build() : nil
        }

        do {
            _ = try await sut.create(userDTO)
            XCTFail("Expected UserError.emailAlreadyExists to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .emailAlreadyExists)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 0)
    }

    func testCreateUser_PhoneNumberAlreadyExists() async throws {
        let userDTO = UserCreateDTOBuilder().build()
        repoMock.findPhoneNumberHandler = { input in
            return input == userDTO.phoneNumber
                ? UserBuilder().withPhoneNumber(
                    userDTO.phoneNumber
                ).build() : nil
        }

        do {
            _ = try await sut.create(userDTO)
            XCTFail("Expected UserError.phoneNumberAlreadyExists to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .phoneNumberAlreadyExists)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
        XCTAssertEqual(repoMock.findPhoneNumberCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 0)
    }

    // MARK: - delete

    func testDeleteUser_Success() async throws {
        let userId = UUID()
        repoMock.findIdHandler = { id in
            return id == userId ? UserBuilder().withId(id).build() : nil
        }

        try await sut.delete(id: userId)

        XCTAssertEqual(repoMock.findIdCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 1)
    }

    func testDeleteUser_UserNotFound() async throws {
        let userId = UUID()
        repoMock.findIdHandler = { _ in
            return nil
        }

        do {
            try await sut.delete(id: userId)
            XCTFail("Expected UserError.userNotFound to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .userNotFound)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
        XCTAssertEqual(repoMock.findIdCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 0)
    }

    // MARK: - update

    func testUpdateUser_Success() async throws {
        let existingUser = UserBuilder().build()
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
        repoMock.findIdHandler = { id in
            return existingUser
        }
        repoMock.findHandler = { _ in
            return nil
        }
        repoMock.findPhoneNumberHandler = { _ in
            return nil
        }

        let updatedUser = try await sut.update(
            id: existingUser.id,
            with: updateData
        )

        // Assert
        XCTAssertNotNil(updatedUser)
        XCTAssertEqual(repoMock.findIdCallCount, 1)
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.findPhoneNumberCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 1)
        XCTAssertEqual(hasherMock.hashCallCount, 1)
    }

    func testUpdateUser_UserNotFound() async {
        let updateData = UserUpdateDTOBuilder().build()
        repoMock.findIdHandler = { _ in nil }

        do {
            _ = try await sut.update(id: UUID(), with: updateData)
            XCTFail("Expected UserError.userNotFound to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .userNotFound)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
        XCTAssertEqual(repoMock.findIdCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    func testUpdateUser_EmailAlreadyExists() async throws {
        let existingUser = UserBuilder().build()
        let updateData = UserUpdateDTOBuilder()
            .withEmail("123a@example.com")
            .build()
        repoMock.findIdHandler = { _ in existingUser }
        repoMock.findPhoneNumberHandler = { _ in return nil }
        repoMock.findHandler = { input in
            return UserBuilder()
                .withId(UUID())
                .withEmail(input)
                .build()
        }

        do {
            _ = try await sut.update(id: UUID(), with: updateData)
            XCTFail("Expected UserError.emailAlreadyExists to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .emailAlreadyExists)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    func testUpdateUser_PhoneNumberAlreadyExists() async throws {
        let existingUser = UserBuilder().build()
        let updateData = UserUpdateDTOBuilder()
            .withPhoneNumber("+0101010101")
            .build()
        repoMock.findIdHandler = { _ in existingUser }
        repoMock.findPhoneNumberHandler = { input in
            return UserBuilder()
                .withId(UUID())
                .withPhoneNumber(input)
                .build()

        }
        repoMock.findHandler = { _ in return nil }

        do {
            _ = try await sut.update(id: UUID(), with: updateData)
            XCTFail("Expected UserError.phoneNumberAlreadyExists to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .phoneNumberAlreadyExists)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
        XCTAssertEqual(repoMock.findPhoneNumberCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }
}
