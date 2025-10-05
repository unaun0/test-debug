//
//  ITrainingRoomService.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public protocol ITrainingRoomService: Sendable {
    func create(_ data: TrainingRoomCreateDTO) async throws -> TrainingRoom?
    func update(id: UUID, with data: TrainingRoomUpdateDTO) async throws -> TrainingRoom?
    func find(id: UUID) async throws -> TrainingRoom?
    func find(name: String) async throws -> TrainingRoom?
    func find(capacity: Int) async throws -> [TrainingRoom]
    func findAll() async throws -> [TrainingRoom]
    func delete(id: UUID) async throws
}
