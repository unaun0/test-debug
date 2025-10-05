//
//  BaseModel.swift
//  Backend
//
//  Created by Цховребова Яна on 03.04.2025.
//

import Vapor

// MARK: - Base Model

public protocol BaseModel: Identifiable, Codable, Equatable {
    var id: UUID { get set }
}
