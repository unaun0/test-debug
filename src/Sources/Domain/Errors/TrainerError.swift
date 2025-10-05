//
//  TrainerError.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.
//

import Vapor

public enum TrainerError: Error {
    case trainerNotFound
    case userAlreadyHasTrainer
    case invalidDescription
    case invalidUserId
    case invalidCreation
    case invalidUpdate
}

extension TrainerError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .trainerNotFound:
            return .notFound
        case .userAlreadyHasTrainer:
            return .conflict
        case .invalidDescription:
            return .badRequest
        case .invalidUserId:
            return .badRequest
        case .invalidCreation:
            return .badRequest
        case .invalidUpdate:
            return .badRequest
        }
    }

    public var reason: String {
        switch self {
        case .trainerNotFound:
            return "Тренер не найден."
        case .userAlreadyHasTrainer:
            return "Пользователь уже является тренером."
        case .invalidUserId:
            return "Неверный идентификатор пользователя - тренера."
        case .invalidDescription:
            return "Неверное описание."
        case .invalidCreation:
            return "Ошибка при создании тренера."
        case .invalidUpdate:
            return "Ошибка при обновлении тренера."
        }
    }
}
