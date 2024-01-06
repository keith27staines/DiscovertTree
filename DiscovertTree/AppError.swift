//
//  AppError.swift
//  DiscoveryTree
//
//  Created by Keith Staines on 02/12/2023.
//

enum AppError: Error {
    case parentNodeIsRequired
    case nodeDoesNotExist
    case operationNotAllowedOnRoot
    case moveIsAmbiguous
    case moveIsTooComplex
    case nodeWouldContainSelf
}
