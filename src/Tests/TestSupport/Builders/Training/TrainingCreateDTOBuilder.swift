//
//  TrainingCreateDTOBuilder.swift
//  Backend
//
//  Created by Tskhovrebova Yana on 07.09.2025.
//

import Vapor
@testable import Domain

final class TrainingCreateDTOBuilder {
    private var date: String? = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let tomorrow = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Date()
        )!
        return formatter.string(from: tomorrow)
    }()
    private var roomId: UUID = UUID()
    private var trainerId: UUID = UUID()

    func withDate(_ date: String) -> Self { self.date = date; return self }
    func withRoomId(_ roomId: UUID) -> Self { self.roomId = roomId; return self }
    func withTrainerId(_ trainerId: UUID) -> Self { self.trainerId = trainerId; return self }

    func build() -> TrainingCreateDTO {
        TrainingCreateDTO(date: date, roomId: roomId, trainerId: trainerId)
    }
}
