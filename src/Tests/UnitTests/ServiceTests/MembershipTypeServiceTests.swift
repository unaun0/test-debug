//
//  MembershipTypeServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor
import XCTest

@testable import Domain
@testable import TestSupport


final class MembershipTypeServiceTests: XCTestCase {
    var repoMock: IMembershipTypeRepositoryMock!
    var sut: MembershipTypeService!

    override func setUp() {
        super.setUp()
        repoMock = IMembershipTypeRepositoryMock()
        sut = MembershipTypeService(repository: repoMock)
    }

    override func tearDown() {
        repoMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - create

    func testCreateMembershipType_Success() async throws {
        let dto = MembershipTypeCreateDTOBuilder().build()
        repoMock.findNameHandler = { _ in nil }

        let result = try await sut.create(dto)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, dto.name)
        XCTAssertEqual(result?.price, dto.price)
        XCTAssertEqual(result?.sessions, dto.sessions)
        XCTAssertEqual(result?.days, dto.days)
        XCTAssertEqual(repoMock.createCallCount, 1)
        XCTAssertEqual(repoMock.findNameCallCount, 1)
    }

    func testCreateMembershipType_NameAlreadyExists() async throws {
        let dto = MembershipTypeCreateDTOBuilder().build()
        repoMock.findNameHandler = { _ in
            MembershipTypeBuilder()
                .withName(dto.name)
                .build()
        }
        
        do {
            _ = try await sut.create(dto)
            XCTFail("Expected MembershipTypeError.nameAlreadyExists")
        } catch let error as MembershipTypeError {
            XCTAssertEqual(error, .nameAlreadyExists)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findNameCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 0)
    }

    // MARK: - update

    func testUpdateMembershipType_Success() async throws {
        let existing = MembershipTypeBuilder().build()
        let dto = MembershipTypeUpdateDTOBuilder()
            .withDays(365)
            .withName("Test")
            .withPrice(1)
            .withSessions(365)
            .build()
        repoMock.findHandler = { _ in existing }
        repoMock.findNameHandler = { _ in nil }

        let result = try await sut.update(id: existing.id, with: dto)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.findNameCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 1)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, dto.name)
        XCTAssertEqual(result?.price, dto.price)
        XCTAssertEqual(result?.sessions, dto.sessions)
        XCTAssertEqual(result?.days, dto.days)
    }

    func testUpdateMembershipType_NotFound() async throws {
        let dto = MembershipTypeUpdateDTOBuilder().build()
        repoMock.findHandler = { _ in nil }

        do {
            _ = try await sut.update(id: UUID(), with: dto)
            XCTFail("Expected MembershipTypeError.membershipTypeNotFound")
        } catch let error as MembershipTypeError {
            XCTAssertEqual(error, .membershipTypeNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    func testUpdateMembershipType_NameAlreadyExists() async throws {
        let existing = MembershipTypeBuilder().build()
        let dto = MembershipTypeUpdateDTOBuilder().withName("Duplicate").build()
        repoMock.findHandler = { _ in existing }
        repoMock.findNameHandler = { _ in
            MembershipTypeBuilder().withName("Duplicate").build()
        }

        do {
            _ = try await sut.update(id: UUID(), with: dto)
            XCTFail("Expected MembershipTypeError.nameAlreadyExists")
        } catch let error as MembershipTypeError {
            XCTAssertEqual(error, .nameAlreadyExists)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.findNameCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }
    
    // MARK: - delete
    
    func testDelete_Success() async throws {
        let membership = MembershipTypeBuilder().build()
        repoMock.findHandler = { id in
            return membership
        }

        try await sut.delete(id: membership.id)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 1)
    }

    func testDelete_NotFound_Throws() async {
        let mtId = UUID()
        repoMock.findHandler = { _ in
            return nil
        }

        do {
            _ = try await sut.delete(id: mtId)
            XCTFail("Expected MembershipTypeError.membershipTypeNotFound")
        } catch let error as MembershipTypeError {
            XCTAssertEqual(error, .membershipTypeNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 0)
    }
}
