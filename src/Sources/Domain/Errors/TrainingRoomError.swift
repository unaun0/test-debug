//
//  TrainingRoomError.swift
//  Backend
//
//  Created by Цховребова Яна on 18.03.2025.
//

import Vapor

public enum TrainingRoomError: Error {
    case trainingRoomNotFound
    case nameAlreadyExists
    case invalidCapacity
    case invalidName
    case invalidCreation
    case invalidUpdate
}

extension TrainingRoomError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .trainingRoomNotFound:
            return .notFound
        case .nameAlreadyExists:
            return .conflict
        case .invalidCapacity:
            return .badRequest
        case .invalidName:
            return .badRequest
        case .invalidCreation, .invalidUpdate:
            return .badRequest
        }
    }

    public var reason: String {
        switch self {
        case .trainingRoomNotFound:
            return "Зал не найден."
        case .nameAlreadyExists:
            return "Зал с таким именем уже существует."
        case .invalidCapacity:
            return "Вместимость зала должна быть больше 0."
        case .invalidName:
            return "Некорректное имя зала."
        case .invalidCreation:
            return "Ошибка при создании зала."
        case .invalidUpdate:
            return "Ошибка при обновлении зала."
        }
    }
}
