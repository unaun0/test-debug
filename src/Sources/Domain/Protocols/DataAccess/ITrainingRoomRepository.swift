//
//  ITrainingRoomRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

/// @mockable
public protocol ITrainingRoomRepository: Sendable {
    func create(_ room: TrainingRoom) async throws
    func update(_ room: TrainingRoom) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> TrainingRoom?
    func find(name: String) async throws -> TrainingRoom?
    func find(capacity: Int) async throws -> [TrainingRoom]
    func findAll() async throws -> [TrainingRoom]
}
