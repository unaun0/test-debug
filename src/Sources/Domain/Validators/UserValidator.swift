//
//  UserValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 11.03.2025.

import Foundation

public struct UserValidator {
    public static let maxEmailLength = 128
    public static let maxPasswordLength = 256
    public static let maxPhoneNumberLength = 32
    public static let maxNameLength = 128
    public static let maxGenderLength = 32
    public static let maxYearsOld = 120
    public static let minYearsOld = 14
    
    public static func validate(email: String) -> Bool {
        guard
            !email.isEmpty, email.count < maxEmailLength
        else { return false }
        
        return isValidRegex(
            email,
            regex: ValidationRegex.Email.regex
        )
    }

    public static func validate(password: String) -> Bool {
        guard
            !password.isEmpty,
            password.count < maxPasswordLength
        else { return false }
        
        return isValidRegex(
            password,
            regex: ValidationRegex.Password.regex
        )
    }

    public static func validate(phoneNumber: String) -> Bool {
        guard
            !phoneNumber.isEmpty,
            phoneNumber.count < maxPhoneNumberLength
        else { return false }
        
        return isValidRegex(
            phoneNumber,
            regex: ValidationRegex.PhoneNumber.regex
        )
    }

    public static func validate(name: String) -> Bool {
        guard
            !name.isEmpty,
            name.count < maxNameLength
        else { return false }
        
        return isValidRegex(
            name,
            regex: ValidationRegex.Name.regex
        )
    }

    public static func validate(date: Date) -> Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents(
            [.year], from: date, to: Date()
        )
        guard
            let age = ageComponents.year
        else { return false }
        
        return age >= minYearsOld && age <= maxYearsOld
    }

    public static func validate(date dateString: String) -> Bool {
        print(dateString)
        guard
            let date = dateString.toDate(
                format: ValidationRegex.DateFormat.format
            )
        else { return false }
        
        return validate(date: date)
    }

    public static func validate(gender: String) -> Bool {
        guard
            !gender.isEmpty,
            gender.count < maxGenderLength
        else { return false }
        
        return UserGender(rawValue: gender) != nil
    }
    
    public static func validate(roleName: String) -> Bool {
        UserRoleName(rawValue: roleName) != nil
    }
}
