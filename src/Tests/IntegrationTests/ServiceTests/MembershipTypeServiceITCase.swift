//
//  MembershipTypeServiceITCase.swift
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

final class MembershipTypeServiceITCase: XCTestCase {
    var fixture: TestAppFixture!
    var repo: IMembershipTypeRepository!
    var sut: MembershipTypeService!

    override func setUp() async throws {
        try await super.setUp()
        
        fixture = try await TestAppFixture()
        repo = MembershipTypeRepository(db: fixture.db)
        sut = MembershipTypeService(repository: repo)
        
        try await self.clearDatabase()
    }

    override func tearDown() async throws {
        try await self.clearDatabase()
        try await fixture.shutdown()
        
        try await super.tearDown()
    }
    
    private func clearDatabase() async throws {
        try await MembershipTypeDBDTO.query(on: fixture.db).delete()
    }

    // MARK: - create

    func testCreateMembershipType_Success() async throws {
        let dto = MembershipTypeCreateDTOBuilder().build()

        let result = try await sut.create(dto)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, dto.name)
        XCTAssertEqual(result?.price, dto.price)
        XCTAssertEqual(result?.sessions, dto.sessions)
        XCTAssertEqual(result?.days, dto.days)
    }

    func testCreateMembershipType_NameAlreadyExists() async throws {
        let name = "MembershipType Name"
        let existingMt = MembershipTypeBuilder()
            .withName(name)
            .build()
        try await MembershipTypeDBDTO(from: existingMt).create(on: fixture.db)
        let dto = MembershipTypeCreateDTOBuilder()
            .withName(name)
            .build()

        do {
            _ = try await sut.create(dto)
            XCTFail("Expected MembershipTypeError.nameAlreadyExists")
        } catch let error as MembershipTypeError {
            XCTAssertEqual(error, .nameAlreadyExists)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - update

    func testUpdateMembershipType_Success() async throws {
        let existingMt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: existingMt).create(on: fixture.db)
        let dto = MembershipTypeUpdateDTOBuilder()
            .withDays(365)
            .withName("Test")
            .withPrice(1)
            .withSessions(365)
            .build()

        let result = try await sut.update(id: existingMt.id, with: dto)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, dto.name)
        XCTAssertEqual(result?.price, dto.price)
        XCTAssertEqual(result?.sessions, dto.sessions)
        XCTAssertEqual(result?.days, dto.days)
    }

    func testUpdateMembershipType_NotFound() async throws {
        let dto = MembershipTypeUpdateDTOBuilder().build()

        do {
            _ = try await sut.update(id: UUID(), with: dto)
            XCTFail("Expected MembershipTypeError.membershipTypeNotFound")
        } catch let error as MembershipTypeError {
            XCTAssertEqual(error, .membershipTypeNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUpdateMembershipType_NameAlreadyExists() async throws {
        let existingMt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: existingMt).create(on: fixture.db)
        let anotherExistingMt = MembershipTypeBuilder()
            .withName("Test Name")
            .build()
        try await MembershipTypeDBDTO(from: anotherExistingMt).create(on: fixture.db)
        let dto = MembershipTypeUpdateDTOBuilder()
            .withName(existingMt.name)
            .build()

        do {
            _ = try await sut.update(id: anotherExistingMt.id, with: dto)
            XCTFail("Expected MembershipTypeError.nameAlreadyExists")
        } catch let error as MembershipTypeError {
            XCTAssertEqual(error, .nameAlreadyExists)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - delete
    
    func testDelete_Success() async throws {
        let mt = MembershipTypeBuilder().build()
        try await MembershipTypeDBDTO(from: mt).create(on: fixture.db)

        try await sut.delete(id: mt.id)
        
        let deletedMt = try await MembershipTypeDBDTO.query(
            on: fixture.db
        ).filter(\.$id == mt.id).first()
        XCTAssertNil(deletedMt)
    }

    func testDelete_NotFound_Throws() async {
        let mtId = UUID()
        
        do {
            _ = try await sut.delete(id: mtId)
            XCTFail("Expected MembershipTypeError.membershipTypeNotFound")
        } catch let error as MembershipTypeError {
            XCTAssertEqual(error, .membershipTypeNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
