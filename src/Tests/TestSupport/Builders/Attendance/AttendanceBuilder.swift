//
//  AttendanceBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Foundation
@testable import Domain

public final class AttendanceBuilder {
    private var id: UUID = UUID()
    private var membershipId: UUID = UUID()
    private var trainingId: UUID = UUID()
    private var status: AttendanceStatus = .waiting
    
    public init() {}
    
    public func withId(_ id: UUID) -> Self { self.id = id; return self }
    public func withMembershipId(_ membershipId: UUID) -> Self { self.membershipId = membershipId; return self }
    public func withTrainingId(_ trainingId: UUID) -> Self { self.trainingId = trainingId; return self }
    public func withStatus(_ status: AttendanceStatus) -> Self { self.status = status; return self }
    
    public func build() -> Attendance {
        return Attendance(
            id: id,
            membershipId: membershipId,
            trainingId: trainingId,
            status: status
        )
    }
}
