import Vapor
import VaporToOpenAPI
import Domain

public final class AuthController: RouteCollection {
    private let service: IAuthService
    private let jwtService: IJWTService
    private let registerMiddleware: RegisterValidationMiddleware
    private let loginMiddleware: LoginValidationMiddleware

    public init(
        authService: IAuthService,
        jwtService: IJWTService,
        registerMiddleware: RegisterValidationMiddleware,
        loginMiddleware: LoginValidationMiddleware

    ) {
        self.service = authService
        self.jwtService = jwtService
        self.registerMiddleware = registerMiddleware
        self.loginMiddleware = loginMiddleware
    }

    public func boot(routes: RoutesBuilder) throws {
        let authRoute = routes.grouped("auth")

        authRoute.grouped(registerMiddleware).post(
            "register",
            use: register
        ).openAPI(
            summary: "Регистрация нового пользователя",
            description:
                "Создание нового аккаунта по email, телефону и паролю.",
            body: .type(RegisterDTO.self),
            response: .type(UserDTO.self)
        )

        authRoute.grouped(loginMiddleware).post(
            "login",
            use: login
        ).openAPI(
            summary: "Аутентификация",
            description: "Получение токена доступа по email и паролю.",
            body: .type(LoginDTO.self),
            response: .type(TokenDTO.self)
        )
    }
}

// MARK: - Routes Realization

extension AuthController {
    @Sendable
    func register(req: Request) async throws -> Response {
        let json = try req.content.decode([String: String].self)
        guard
            let email = json["email"],
            let phoneNumber = json["phoneNumber"],
            let password = json["password"],
            let firstName = json["firstName"],
            let lastName = json["lastName"],
            let birthDateString = json["birthDate"],
            let genderString = json["gender"]
        else {
            throw UserError.invalidData
        }
        guard let gender = UserGender(rawValue: genderString.lowercased())
        else {
            throw UserError.invalidGender
        }
        let registerDTO = RegisterDTO(
            email: email,
            phoneNumber: phoneNumber,
            password: password,
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDateString,
            gender: gender
        )
        guard let user = try await service.register(registerDTO) else {
            throw AuthError.registerFailed
        }
        return try await UserDTO(from: user).encodeResponse(
            status: .created,
            for: req
        )
    }

    @Sendable
    func login(req: Request) async throws -> Response {
        let data = try req.content.decode(LoginDTO.self)
        guard let user = try await service.login(data) else {
            throw AuthError.loginFailed
        }
        let token = try jwtService.generateToken(
            for: user.id, req: req
        )
        req.auth.login(user)
        let response = Response(status: .ok)
        response.headers.replaceOrAdd(
            name: .authorization,
            value: "Bearer \(token)"
        )
        try response.content.encode(TokenDTO(token: token))

        return response
    }
}

extension AuthController: @unchecked Sendable {}
