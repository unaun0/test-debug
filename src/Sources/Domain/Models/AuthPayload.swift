//
//  AuthPayload.swift
//  Backend
//
//  Created by Цховребова Яна on 19.03.2025.
//

import Vapor
import JWT

public struct AuthPayload: JWTPayload {
    public var id: UUID
    public var exp: ExpirationClaim

    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
