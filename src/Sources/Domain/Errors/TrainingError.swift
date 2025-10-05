//
//  TrainingError.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

public enum TrainingError: Error {
    case trainingNotFound
    case specializationNotFound
    case roomNotFound
    case trainerNotFound
    case invalidDate
    case invalidTime
    case invalidTrainer
    case invalidSpecialization
    case invalidRoom
    case invalidData
    case invalidCreation
    case invalidUpdate
}

extension TrainingError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .trainingNotFound:
            return .notFound
        case .specializationNotFound:
            return .notFound
        case .roomNotFound:
            return .notFound
        case .trainerNotFound:
            return .notFound
        case .invalidTrainer:
            return .notFound
        case .invalidSpecialization:
            return .notFound
        case .invalidRoom:
            return .notFound
        case .invalidData:
            return .notFound
        case .invalidDate:
            return .badRequest
        case .invalidTime:
            return .badRequest
        case .invalidCreation, .invalidUpdate:
            return .badRequest
        }
    }

    public var reason: String {
        switch self {
        case .trainingNotFound:
            return "Тренировка не найдена."
        case .specializationNotFound:
            return "Специализация не найдена."
        case .roomNotFound:
            return "Зал не найден."
        case .trainerNotFound:
            return "Тренер не найден."
        case .invalidDate:
            return "Неверная дата проведения тренировки."
        case .invalidTime:
            return "Неверное время проведения тренировки."
        case .invalidTrainer:
            return "Неверный идентификатор тренера."
        case .invalidSpecialization:
            return "Неверный идентификатор специализации."
        case .invalidRoom:
            return "Неверный идентификатор зала."
        case .invalidData:
            return "Неверные данные тренировки"
        case .invalidCreation:
            return "Ошибка при создании тренировки."
        case .invalidUpdate:
            return "Ошибка при обновлении тренировки."
        }
    }
}
