import Logging
import NIOCore
import NIOPosix
import Vapor

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()

        guard let configPath = Environment.get("CONFIG_PATH") else {
            fatalError("CONFIG_PATH not set in environment.")
        }
        let configData = try Data(
            contentsOf: URL(fileURLWithPath: configPath)
        )
        let appConfig = try JSONDecoder().decode(
            AppConfig.self, from: configData
        )
        try LoggingSystem.bootstrap(
            from: &env,
            label: "",
            logFilePath: appConfig.logging.logFilePath,
            logLevel: appConfig.logging.logLevel
        )
        let app = try await Application.make(env)
        app.setAppConfig(appConfig)
        
        app.http.server.configuration.hostname = "127.0.0.1"
        app.http.server.configuration.port = 8010
        
        do {
            try await configure(app)
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}

extension Application {
    var appConfig: AppConfig {
        guard let config = self.storage[AppConfigKey.self] else {
            fatalError(
                "AppConfig not set. Make sure it's initialized in Entrypoint.main."
            )
        }
        return config
    }

    func setAppConfig(_ config: AppConfig) {
        self.storage[AppConfigKey.self] = config
    }
}
