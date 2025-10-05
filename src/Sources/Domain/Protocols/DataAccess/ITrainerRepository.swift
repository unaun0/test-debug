//
//  ITrainerRepository.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor

/// @mockable
public protocol ITrainerRepository: Sendable {
    func create(_ trainer: Trainer) async throws
    func update(_ trainer: Trainer) async throws
    func delete(id: UUID) async throws
    func find(id: UUID) async throws -> Trainer?
    func find(userId: UUID) async throws -> Trainer?
    func findAll() async throws -> [Trainer]
}
