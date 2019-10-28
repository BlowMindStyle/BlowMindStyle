public protocol StyleEnvironmentChangeDetectorType {
    associatedtype Environment: StyleEnvironmentType
    static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool
}

public struct EnvironmentChange {
    public struct `Any`<Environment: StyleEnvironmentType>: StyleEnvironmentChangeDetectorType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            true
        }
    }

    public struct AnyTraitCollection<Environment: StyleEnvironmentType>: StyleEnvironmentChangeDetectorType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.propertyChanged(\.traitCollection)
        }
    }

    public struct UserInterfaceStyle<Environment: StyleEnvironmentType>: StyleEnvironmentChangeDetectorType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.userInterfaceStyleChanged || arg.userInterfaceLevelChanged
        }
    }

    public struct Locale<Environment: StyleEnvironmentType>: StyleEnvironmentChangeDetectorType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.propertyChanged(\.locale)
        }
    }

    public struct Theme<Environment: StyleEnvironmentType>: StyleEnvironmentChangeDetectorType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.propertyChanged(\.theme)
        }
    }

    public struct ThemeOrUserInterfaceStyle<Environment: StyleEnvironmentType>: StyleEnvironmentChangeDetectorType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            Theme.needUpdate(arg) || UserInterfaceStyle.needUpdate(arg)
        }
    }
}
