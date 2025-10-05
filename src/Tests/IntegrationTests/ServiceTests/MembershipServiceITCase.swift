//
//  MembershipServiceITCase.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 28.09.2025.
//

import Vapor
import XCTest
import Fluent
import FluentPostgresDriver

@testable import Domain
@testable import DataAccess
@testable import TestSupport

final class MembershipServiceITCase: XCTestCase {
    var fixture: TestAppFixture!
    var mtService: IMembershipTypeService!
    var mtRepo: IMembershipTypeRepository!
    var repo: IMembershipRepository!
    var sut: MembershipService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        mtRepo = MembershipTypeRepository(db: fixture.db)
        mtService = MembershipTypeService(repository: mtRepo)
        repo = MembershipRepository(db: fixture.db)
        sut = MembershipService(
            membershipRepository: repo,
            membershipTypeService: mtService
        )
        
        try await self.clearDatabase()
    }
    
    override func tearDown() async throws {
        try await self.clearDatabase()
        try await fixture.shutdown()
        
        try await super.tearDown()
    }
    
    private func clearDatabase() async throws {
        try await MembershipDBDTO.query(on: fixture.db).delete()
        try await MembershipTypeDBDTO.query(on: fixture.db).delete()
        try await UserDBDTO.query(on: fixture.db).delete()
    }
    
    // MARK: - create

    func testCreateMembership_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let dto = MembershipCreateDTOBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .build()

        let result = try await sut.create(dto)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.userId, dto.userId)
        XCTAssertEqual(result?.membershipTypeId, dto.membershipTypeId)
        XCTAssertEqual(result?.availableSessions, mt.sessions)
    }

    func testCreateMembership_InvalidMembershipTypeId() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let dto = MembershipCreateDTOBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(UUID())
            .build()

        do {
            _ = try await sut.create(dto)
            XCTFail("Expected MembershipError.invalidMembershipTypeId")
        } catch let error as MembershipError {
            XCTAssertEqual(error, .invalidMembershipTypeId)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - update

    func testUpdateMembership_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let membership = MembershipBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .build()
        try await MembershipDBDTO(from: membership).create(on: fixture.db)
        let dto = MembershipUpdateDTOBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .withAvailableSessions(15)
            .build()

        let result = try await sut.update(id: membership.id, with: dto)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.userId, dto.userId)
        XCTAssertEqual(result?.membershipTypeId, dto.membershipTypeId)
        XCTAssertEqual(result?.availableSessions, dto.availableSessions)
    }

    func testUpdateMembership_NotFound() async throws {
        let dto = MembershipUpdateDTOBuilder().build()
        
        do {
            _ = try await sut.update(id: UUID(), with: dto)
            XCTFail("Expected MembershipError.membershipNotFound")
        } catch let error as MembershipError {
            XCTAssertEqual(error, .membershipNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - delete
    
    func testDeleteMembership_Success() async throws {
        let user = UserBuilder().build()
        try await UserDBDTO(from: user).create(on: fixture.db)
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)
        let membership = MembershipBuilder()
            .withUserId(user.id)
            .withMembershipTypeId(mt.id)
            .build()
        try await MembershipDBDTO(from: membership).create(on: fixture.db)

        try await sut.delete(id: membership.id)

        let deletedM = try await MembershipDBDTO.query(
            on: fixture.db
        ).filter(\.$id == membership.id).first()
        XCTAssertNil(deletedM)
    }
    
    func testDeleteMembership_NotFound() async throws {
        do {
            _ = try await sut.delete(id: UUID())
            XCTFail("Expected MembershipError.membershipNotFound")
        } catch let error as MembershipError {
            XCTAssertEqual(error, .membershipNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
