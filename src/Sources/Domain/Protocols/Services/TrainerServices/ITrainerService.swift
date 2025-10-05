//
//  ITrainerService.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor

public protocol ITrainerService: Sendable {
    func create(_ data: TrainerCreateDTO) async throws -> Trainer?
    func update(id: UUID, with data: TrainerUpdateDTO) async throws -> Trainer?
    func find(id: UUID) async throws -> Trainer?
    func find(userId: UUID) async throws -> Trainer?
    func findAll() async throws -> [Trainer]
    func delete(id: UUID) async throws
}
