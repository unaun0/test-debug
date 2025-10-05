//
//  TrainingTrainerService.swift
//  Backend
//
//  Created by Цховребова Яна on 11.05.2025.
//

import Fluent
import Vapor

public final class TrainingTrainerService {
    private let tService: ITrainingService
    private let rService: ITrainingRoomService
    private let trService: ITrainerService
    private let uService: IUserService

    public init(
        trainingService: ITrainingService,
        roomService: ITrainingRoomService,
        trainerService: ITrainerService,
        userService: IUserService
    ) {
        self.tService = trainingService
        self.rService = roomService
        self.trService = trainerService
        self.uService = userService
    }
}

// MARK: - ITrainingTrainerService

extension TrainingTrainerService: ITrainingTrainerService {
    public func findAllTrainings(userId: UUID) async throws -> [TrainingInfoDTO] {
        guard let trainer = try await trService.find(
            userId: userId
        ) else {
            throw TrainingError.invalidTrainer
        }
        let allTrainings = try await tService.find(trainerId: trainer.id)
        var result: [TrainingInfoDTO] = []
        for training in allTrainings {
            async let trainer = trainer
            async let room = try rService.find(id: training.roomId)

            guard
                let u = try await uService.find(id: userId),
                let r = try await room
            else {
                throw TrainingError.trainingNotFound
            }
            let trainerDTO = await TrainerInfoDTO(
                id: trainer.id,
                userId: u.id,
                description: trainer.description,
                firstName: u.firstName,
                lastName: u.lastName
            )
            let roomDTO = TrainingRoomDTO(
                id: r.id,
                name: r.name,
                capacity: r.capacity
            )
            let trainingDTO = TrainingInfoDTO(
                id: training.id,
                date: training.date,
                trainer: trainerDTO,
                room: roomDTO
            )
            result.append(trainingDTO)
        }
        return result
    }

    public func findAvailableTrainings(userId: UUID) async throws
        -> [TrainingInfoDTO]
    {
        guard let trainer = try await trService.find(
            userId: userId
        ) else {
            throw TrainingError.invalidTrainer
        }
        let allTrainings = try await tService.find(trainerId: trainer.id)
        let now = Date()
        let futureTrainings = allTrainings.filter { $0.date > now }
        var result: [TrainingInfoDTO] = []
        for training in futureTrainings {
            async let room = try rService.find(id: training.roomId)

            guard
                let u = try await uService.find(id: userId),
                let r = try await room
            else {
                throw TrainingError.trainingNotFound
            }

            let trainerDTO = TrainerInfoDTO(
                id: trainer .id,
                userId: u.id,
                description: trainer.description,
                firstName: u.firstName,
                lastName: u.lastName
            )
            let roomDTO = TrainingRoomDTO(
                id: r.id,
                name: r.name,
                capacity: r.capacity
            )
            let trainingDTO = TrainingInfoDTO(
                id: training.id,
                date: training.date,
                trainer: trainerDTO,
                room: roomDTO
            )
            result.append(trainingDTO)
        }
        return result
    }
}
