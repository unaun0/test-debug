//
//  AttendanceError.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

public enum AttendanceError: Error {
    case attendanceNotFound
    case invalidStatus
    case invalidMembershipId
    case invalidTrainingId
    case invalidMembershipTrainingUnique
    case invalidCreation
    case invalidUpdate
}

extension AttendanceError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .attendanceNotFound:
            return .notFound
        case .invalidStatus:
            return .badRequest
        case .invalidMembershipId:
            return .badRequest
        case .invalidTrainingId:
            return .badRequest
        case .invalidMembershipTrainingUnique:
            return .conflict
        case .invalidCreation, .invalidUpdate:
            return .badRequest
        }
    }

    public var reason: String {
        switch self {
        case .attendanceNotFound:
            return "Посещение не найдено."
        case .invalidStatus:
            return "Неверный статус посещения."
        case .invalidMembershipTrainingUnique:
            return "Владелец абонемента уже записан на выбранную тренировку."
        case .invalidMembershipId:
            return "Неверный идентификатор абонемента."
        case .invalidTrainingId:
            return "Неверный идентификатор тренировки."
        case .invalidCreation, .invalidUpdate:
            return "Ошибка при создании / обновлении посещения."
        }
    }
}
