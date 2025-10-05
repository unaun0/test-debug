//
//  TrainingBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Vapor
@testable import Domain

final class TrainingBuilder {
    private var id = UUID()
    private var date = Calendar.current.date(
        byAdding: .day,
        value: 1,
        to: Date()
    )!
    private var roomId = UUID()
    private var trainerId = UUID()

    func withId(_ id: UUID) -> Self { self.id = id; return self }
    func withRoomId(_ roomId: UUID) -> Self { self.roomId = roomId; return self }
    func withTrainerId(_ trainerId: UUID) -> Self { self.trainerId = trainerId; return self }
    func withDate(_ date: Date) -> Self { self.date = date; return self }

    func build() -> Training {
        Training(
            id: id,
            date: date,
            roomId: roomId,
            trainerId: trainerId,
        )
    }
}
