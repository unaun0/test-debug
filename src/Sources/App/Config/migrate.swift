//
//  migrate.swift
//  Backend
//
//  Created by Цховребова Яна on 29.05.2025.
//

import Vapor
import Fluent
import DataAccess
import Domain

func migrateAll(app: Application) async throws {
    try await migrateUsers(app: app)
    try await migrateTrainers(app: app)
    try await migrateMembershipTypes(app: app)
    try await migrateMemberships(app: app)
    try await migrateTrainings(app: app)
}

// MARK: - Individual Migrations

func migrateUsers(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await UserDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toUser() else { continue }
        let mongoModel = UserMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) users")
}

func migrateTrainers(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await TrainerDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toTrainer() else { continue }
        let mongoModel = TrainerMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) trainers")
}

func migrateMembershipTypes(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await MembershipTypeDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toMembershipType() else { continue }
        let mongoModel = MembershipTypeMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) membership types")
}

func migrateMemberships(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo
    
    let pgModels = try await MembershipDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toMembership() else { continue }
        let mongoModel = MembershipMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) memberships")
}

func migrateTrainings(app: Application) async throws {
    let postgres = app.postgres
    let mongo = app.mongo

    let pgModels = try await TrainingDBDTO.query(on: postgres).all()

    for pg in pgModels {
        guard let domain = pg.toTraining() else { continue }
        let mongoModel = TrainingMongoDBDTO(from: domain)
        try await mongoModel.create(on: mongo)
    }

    app.logger.info("✅ Migrated \(pgModels.count) trainings")
}
