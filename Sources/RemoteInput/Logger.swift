import OSLog

extension Logger {
    //private static var subsystem = Bundle.main.bundleIdentifier!
    private static var subsystem = "com.radugin.RemoteInput"

    static let contentView = Logger(subsystem: subsystem, category: "contentView")
    static let contentViewViewModel = Logger(subsystem: subsystem, category: "viewModel")
    static let reportController = Logger(subsystem: subsystem, category: "reportController")
    static let bleService = Logger(subsystem: subsystem, category: "bleService")
    static let app = Logger(subsystem: subsystem, category: "app")
}
