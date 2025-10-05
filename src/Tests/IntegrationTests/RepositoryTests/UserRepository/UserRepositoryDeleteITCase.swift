//
//  UserRepositoryDeleteITCase.swift
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

final class UserRepositoryDeleteITCase: XCTestCase {
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
    
    func testDeleteUser_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        
        try await sut.delete(id: user.id)
        
        let deletedUser = try await UserDBDTO.query(
            on: fixture.db
        ).filter(\.$id == user.id).first()
        XCTAssertNil(deletedUser)
    }
    
    func testDeleteUser_NotFound() async throws {
        do {
            try await sut.delete(id: UUID())
            XCTFail("Expected UserRepositoryError but none was thrown")
        } catch let error as UserRepositoryError {
            XCTAssertEqual(UserRepositoryError.userNotFound, error)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
