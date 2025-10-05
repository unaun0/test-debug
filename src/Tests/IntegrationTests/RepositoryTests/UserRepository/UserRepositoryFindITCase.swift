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

final class UserRepositoryFindITCase: XCTestCase {
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

    func testFindUserById_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        
        let foundUser = try await sut.find(id: user.id)
            
        XCTAssertNotNil(foundUser)
        XCTAssertEqual(user.email, foundUser?.email)
        XCTAssertEqual(user.phoneNumber, foundUser?.phoneNumber)
        XCTAssertEqual(user.firstName, foundUser?.firstName)
        XCTAssertEqual(user.lastName, foundUser?.lastName)
        XCTAssertEqual(user.password, foundUser?.password)
        XCTAssertEqual(user.role, foundUser?.role)
        XCTAssertEqual(user.gender, foundUser?.gender)
    }
    
    func testFindUserById_NotFound() async throws {
        let foundUser = try await sut.find(id: UUID())
            
        XCTAssertNil(foundUser)
    }
    
    func testFindUserByEmail_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        
        let foundUser = try await sut.find(email: user.email)
            
        XCTAssertNotNil(foundUser)
        XCTAssertEqual(user.id, foundUser?.id)
        XCTAssertEqual(user.phoneNumber, foundUser?.phoneNumber)
        XCTAssertEqual(user.firstName, foundUser?.firstName)
        XCTAssertEqual(user.lastName, foundUser?.lastName)
        XCTAssertEqual(user.password, foundUser?.password)
        XCTAssertEqual(user.role, foundUser?.role)
        XCTAssertEqual(user.gender, foundUser?.gender)
    }
    
    func testFindUserByEmail_NotFound() async throws {
        let foundUser = try await sut.find(email: "test@email.email")
            
        XCTAssertNil(foundUser)
    }
    
    func testFindUserByPhone_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        
        let foundUser = try await sut.find(phoneNumber: user.phoneNumber)
            
        XCTAssertNotNil(foundUser)
        XCTAssertEqual(user.id, foundUser?.id)
        XCTAssertEqual(user.phoneNumber, foundUser?.phoneNumber)
        XCTAssertEqual(user.firstName, foundUser?.firstName)
        XCTAssertEqual(user.lastName, foundUser?.lastName)
        XCTAssertEqual(user.password, foundUser?.password)
        XCTAssertEqual(user.role, foundUser?.role)
        XCTAssertEqual(user.gender, foundUser?.gender)
    }
    
    func testFindUserByPhone_NotFound() async throws {
        let foundUser = try await sut.find(phoneNumber: "+799999999999")
            
        XCTAssertNil(foundUser)
    }
    
    func testFindUserAll_Success() async throws {
        let firstUser = UserBuilder().build()
        try await UserDBDTO(from: firstUser).create(on: fixture.db)
        let secondUser = UserBuilder().withEmail("e@e.e").withPhoneNumber("+1234567890").build()
        try await UserDBDTO(from: secondUser).create(on: fixture.db)
        
        let foundUsers = try await sut.findAll()
            
        
        XCTAssertNotNil(foundUsers)
        XCTAssertEqual(foundUsers.count, 2)
        
        let foundFirstUser = foundUsers.first { $0.id == firstUser.id }
        let foundSecondUser = foundUsers.first { $0.id == secondUser.id }
        
        XCTAssertNotNil(foundFirstUser)
        XCTAssertEqual(foundFirstUser?.id, firstUser.id)
        XCTAssertEqual(foundFirstUser?.email, firstUser.email)
        XCTAssertEqual(foundFirstUser?.phoneNumber, firstUser.phoneNumber)
        XCTAssertEqual(foundFirstUser?.firstName, firstUser.firstName)
        XCTAssertEqual(foundFirstUser?.lastName, firstUser.lastName)
        XCTAssertEqual(foundFirstUser?.password, firstUser.password)
        XCTAssertEqual(foundFirstUser?.role, firstUser.role)
        XCTAssertEqual(foundFirstUser?.gender, firstUser.gender)

        XCTAssertNotNil(foundSecondUser)
        XCTAssertEqual(foundSecondUser?.id, secondUser.id)
        XCTAssertEqual(foundSecondUser?.email, secondUser.email)
        XCTAssertEqual(foundSecondUser?.phoneNumber, secondUser.phoneNumber)
        XCTAssertEqual(foundSecondUser?.firstName, secondUser.firstName)
        XCTAssertEqual(foundSecondUser?.lastName, secondUser.lastName)
        XCTAssertEqual(foundSecondUser?.password, secondUser.password)
        XCTAssertEqual(foundSecondUser?.role, secondUser.role)
        XCTAssertEqual(foundSecondUser?.gender, secondUser.gender)
    }
    
    func testFindUserAll_NotFound() async throws {
        let foundUsers = try await sut.findAll()
            
        XCTAssertTrue(foundUsers.isEmpty)
    }
}
