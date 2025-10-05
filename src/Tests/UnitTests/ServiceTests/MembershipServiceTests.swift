//
//  MembershipServiceTests.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor
import XCTest

@testable import Domain
@testable import TestSupport

final class MembershipServiceTests: XCTestCase {
    private var repoMock: IMembershipRepositoryMock!
    private var srvMock: IMembershipTypeServiceMock!
    private var sut: MembershipService!

    override func setUp() {
        super.setUp()
        repoMock = IMembershipRepositoryMock()
        srvMock = IMembershipTypeServiceMock()
        sut = MembershipService(
            membershipRepository: repoMock,
            membershipTypeService: srvMock
        )
    }

    override func tearDown() {
        repoMock = nil
        srvMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - create

    func testCreateMembership_Success() async throws {
        let membershipType = MembershipTypeBuilder().build()
        srvMock.findHandler = { _ in membershipType }
        let dto = MembershipCreateDTOBuilder()
            .withUserId(UUID())
            .withMembershipTypeId(membershipType.id)
            .build()

        let result = try await sut.create(dto)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.userId, dto.userId)
        XCTAssertEqual(result?.membershipTypeId, dto.membershipTypeId)
        XCTAssertEqual(result?.availableSessions, membershipType.sessions)
        XCTAssertEqual(srvMock.findCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 1)
    }

    func testCreateMembership_InvalidMembershipTypeId() async throws {
        let dto = MembershipCreateDTOBuilder()
            .withUserId(UUID())
            .withMembershipTypeId(UUID())
            .build()
        srvMock.findHandler = { _ in nil }

        do {
            _ = try await sut.create(dto)
            XCTFail("Expected MembershipError.invalidMembershipTypeId")
        } catch let error as MembershipError {
            XCTAssertEqual(error, .invalidMembershipTypeId)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(srvMock.findCallCount, 1)
        XCTAssertEqual(repoMock.createCallCount, 0)
    }

    // MARK: - update

    func testUpdateMembership_Success() async throws {
        let membership = MembershipBuilder().build()
        repoMock.findHandler = { _ in membership }
        let dto = MembershipUpdateDTOBuilder()
            .withUserId(UUID())
            .withMembershipTypeId(UUID())
            .withAvailableSessions(15)
            .build()

        let result = try await sut.update(id: membership.id, with: dto)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.userId, dto.userId)
        XCTAssertEqual(result?.membershipTypeId, dto.membershipTypeId)
        XCTAssertEqual(result?.availableSessions, dto.availableSessions)
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 1)
    }

    func testUpdateMembership_NotFound() async throws {
        repoMock.findHandler = { _ in nil }
        let dto = MembershipUpdateDTOBuilder().build()
        
        do {
            _ = try await sut.update(id: UUID(), with: dto)
            XCTFail("Expected MembershipError.membershipNotFound")
        } catch let error as MembershipError {
            XCTAssertEqual(error, .membershipNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.updateCallCount, 0)
    }

    // MARK: - delete
    
    func testDeleteMembership_Success() async throws {
        let membership = MembershipBuilder().build()
        repoMock.findHandler = { _ in membership }

        try await sut.delete(id: membership.id)

        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 1)
    }
    
    func testDeleteMembership_NotFound() async throws {
        repoMock.findHandler = { _ in nil }

        do {
            _ = try await sut.delete(id: UUID())
            XCTFail("Expected MembershipError.membershipNotFound")
        } catch let error as MembershipError {
            XCTAssertEqual(error, .membershipNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(repoMock.findCallCount, 1)
        XCTAssertEqual(repoMock.deleteCallCount, 0)
    }
}
