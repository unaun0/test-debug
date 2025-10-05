//
//  AuthServiceITCase.swift
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

final class AuthServiceITCase: XCTestCase {
    var fixture: TestAppFixture!
    var repo: IUserRepository!
    var hasher: IHasherService!
    var service: IUserService!
    var sut: AuthService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        repo = UserRepository(db: fixture.db)
        hasher = BcryptHasherService()
        service = UserService(
            userRepository: repo,
            passwordHasher: hasher
        )
        sut = AuthService(
            userService: service,
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
    
    func testRegister_Success() async throws {
        let registerDto = RegisterDTOBuilder()
            .withEmail("email@example.com")
            .withPhoneNumber("+1234567890")
            .withPassword("password123")
            .build()
        
        _ = try await sut.register(registerDto)
        
        let user = try await UserDBDTO.query(
            on: fixture.db
        ).filter(\.$email == registerDto.email).first()
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.email, registerDto.email)
        XCTAssertEqual(user?.phoneNumber, registerDto.phoneNumber)
    }
    
    func testRegister_InvalidEmail() async throws {
        let user = UserBuilder()
            .withEmail("email@example.com")
            .build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let registerDto = RegisterDTOBuilder()
            .withEmail("email@example.com")
            .withPhoneNumber("+1234567890")
            .withPassword("password123")
            .build()
        
        do {
            _ = try await sut.register(registerDto)
            XCTFail("Expected UserError to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .emailAlreadyExists)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }
    
    func testRegister_InvalidPhoneNumber() async throws {
        let user = UserBuilder()
            .withPhoneNumber("+1234567890")
            .build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let registerDto = RegisterDTOBuilder()
            .withEmail("email@example.com")
            .withPhoneNumber("+1234567890")
            .withPassword("password123")
            .build()
        
        do {
            _ = try await sut.register(registerDto)
            XCTFail("Expected UserError to be thrown")
        } catch let error as UserError {
            XCTAssertEqual(error, .phoneNumberAlreadyExists)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }
    
    func testLogin_SuccessByEmail() async throws {
        let password = "Pass12345"
        let existingUser = UserBuilder()
            .withPhoneNumber("+1234567890")
            .withEmail("test@test.test")
            .withPassword(try hasher.hash(password))
            .build()
        try await UserDBDTO(from: existingUser).create(on: fixture.db)
        
        let loginDto = LoginDTO(
            login: existingUser.email,
            password: password
        )
        
        let user = try await sut.login(loginDto)
        
        XCTAssertNotNil(user )
        XCTAssertEqual(user?.email, existingUser.email)
        XCTAssertEqual(user?.phoneNumber, existingUser.phoneNumber)
    }

    func testLogin_SuccessByPhoneNumber() async throws {
        let password = "Pass12345"
        let existingUser = UserBuilder()
            .withPhoneNumber("+1234567890")
            .withEmail("test@test.test")
            .withPassword(try hasher.hash(password))
            .build()
        try await UserDBDTO(from: existingUser).create(on: fixture.db)
        
        let loginDto = LoginDTO(
            login: existingUser.phoneNumber,
            password: password
        )
        
        let user = try await sut.login(loginDto)
        
        XCTAssertNotNil(user )
        XCTAssertEqual(user?.email, existingUser.email)
        XCTAssertEqual(user?.phoneNumber, existingUser.phoneNumber)
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
        let password = "Pass12345"
        let existingUser = UserBuilder()
            .withPhoneNumber("+1234567890")
            .withEmail("test@test.test")
            .withPassword(try hasher.hash(password))
            .build()
        try await UserDBDTO(from: existingUser).create(on: fixture.db)
        
        let loginDto = LoginDTO(
            login: existingUser.email,
            password: "InvalidPass12345"
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
