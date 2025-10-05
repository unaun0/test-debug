//
//  AttendanceUpdateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Foundation
@testable import Domain

public final class AttendanceUpdateDTOBuilder {
    private var membershipId: UUID? = nil
    private var trainingId: UUID? = nil
    private var status: AttendanceStatus? = nil
    
    public init() {}
    
    public func withMembershipId(_ membershipId: UUID?) -> Self { self.membershipId = membershipId; return self }
    public func withTrainingId(_ trainingId: UUID?) -> Self { self.trainingId = trainingId; return self }
    public func withStatus(_ status: AttendanceStatus?) -> Self { self.status = status; return self }
    
    public func build() -> AttendanceUpdateDTO {
        return AttendanceUpdateDTO(
            membershipId: membershipId,
            trainingId: trainingId,
            status: status
        )
    }
}
