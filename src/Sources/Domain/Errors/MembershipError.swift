//
//  MembershipError.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor

public enum MembershipError: Error {
    case membershipNotFound
    case invalidStartDate
    case invalidEndDate
    case invalidDate
    case invalidAvailableSessions
    case invalidMembershipTypeId
    case invalidUserId
    case orderNotFound
    case userNotFound
    case membershipTypeNotFound
    case invalidCreation
    case invalidUpdate
}

extension MembershipError: AbortError {
    public var status: HTTPStatus {
        switch self {
        case .membershipNotFound:
            return .notFound
        case .orderNotFound:
            return .notFound
        case .userNotFound:
            return .notFound
        case .membershipTypeNotFound:
            return .notFound
        case .invalidStartDate:
            return .badRequest
        case .invalidEndDate:
            return .badRequest
        case .invalidAvailableSessions:
            return .badRequest
        case .invalidDate:
            return .badRequest
        case .invalidMembershipTypeId:
            return .badRequest
        case .invalidUserId:
            return .badRequest
        case .invalidCreation, .invalidUpdate:
            return .badRequest
        }
    }

    public var reason: String {
        switch self {
        case .membershipNotFound:
            return "Абонемент не найден."
        case .invalidStartDate:
            return "Неверная дата начала действия абонемента."
        case .invalidEndDate:
            return "Неверная дата окончания действия абонемента."
        case .invalidAvailableSessions:
            return "Неверное количество доступных занятий."
        case .orderNotFound:
            return "Заказ не найден."
        case .userNotFound:
            return "Пользователь не найден."
        case .membershipTypeNotFound:
            return "Тип абонемента не найден."
        case .invalidDate:
            return "Неверные даты начала и конца действия абонемента."
        case .invalidMembershipTypeId:
            return "Неверный идентификатор типа абонемента."
        case .invalidUserId:
            return "Неверный идентификатор пользователя."
        case .invalidCreation, .invalidUpdate:
            return "Ошибка при создании / обновления абонемента."
        }
    }
}
