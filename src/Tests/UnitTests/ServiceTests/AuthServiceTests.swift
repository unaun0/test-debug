//
//  AuthServiceTests.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Vapor
import XCTest

@testable import Domain
@testable import TestSupport

final class AuthServiceFixture {
    var repoFake: IUserRepositoryFake!
    var hasher: IHasherService!
    var service: UserService!

    init() {}

    func setUp() async throws {
        repoFake = IUserRepositoryFake()
        hasher = IHasherServiceFake()
        service = UserService(
            userRepository: repoFake,
            passwordHasher: hasher
        )
    }

    func shutdown() async throws {
        repoFake = nil
        hasher = nil
        service = nil
    }
}

final class AuthServiceTests: XCTestCase {
    var fixture: AuthServiceFixture!
    var sut: AuthService!
    
    override func setUp() async throws {
        try await super.setUp()
        fixture = AuthServiceFixture()
        try await fixture.setUp()
        sut = AuthService(
            userService: fixture.service,
            passwordHasher: fixture.hasher
        )
    }

    override func tearDown() async throws {
        sut = nil
        try await fixture.shutdown()
        fixture = nil
        try await super.tearDown()
    }

    func testLogin_SuccessByEmail() async throws {
        let registerDto = RegisterDTOBuilder()
            .withEmail("email@example.com")
            .withPhoneNumber("+1234567890")
            .withPassword("password123")
            .build()
        _ = try await sut.register(registerDto)
        let loginDto = LoginDTO(
            login: registerDto.email,
            password: registerDto.password
        )
        
        let user = try await sut.login(loginDto)
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.email, registerDto.email)
        XCTAssertEqual(user?.phoneNumber, registerDto.phoneNumber)
    }

    func testLogin_SuccessByPhoneNumber() async throws {
        let registerDto = RegisterDTOBuilder()
            .withPhoneNumber("+9998887777")
            .withPassword("password123")
            .build()
        _ = try await sut.register(registerDto)
        let loginDto = LoginDTO(
            login: registerDto.phoneNumber,
            password: registerDto.password
        )
        
        let user = try await sut.login(loginDto)
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.email, registerDto.email)
        XCTAssertEqual(user?.phoneNumber, registerDto.phoneNumber)
    }

    func testLogin_UserNotFound() async {
        let loginDto = LoginDTO(
            login: "nonexistent@example.com",
            password: "anyPass"
        )
        
        do {
            _ = try await sut.login(loginDto)
            XCTFail("Expected UserError.userNotFound to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .userNotFound)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    func testLogin_InvalidPassword() async throws {
        let registerDto = RegisterDTOBuilder()
            .withEmail("secure@example.com")
            .withPhoneNumber("+111222333")
            .withPassword("correctPass")
            .build()
        _ = try await sut.register(registerDto)
        let loginDto = LoginDTO(
            login: registerDto.email,
            password: "wrongPass"
        )
        
        do {
            _ = try await sut.login(loginDto)
            XCTFail("Expected UserError.invalidPassword to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .invalidPassword)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
