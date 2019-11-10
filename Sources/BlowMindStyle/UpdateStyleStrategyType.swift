import UIKit

public protocol UpdateStyleStrategyType {
    associatedtype Environment: StyleEnvironmentType
    static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool
}

public struct EnvironmentChange {
    public struct `Any`<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            true
        }
    }

    public struct AnyTraitCollection<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.propertyChanged(\.traitCollection)
        }
    }

    public struct UserInterfaceStyle<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            if #available(iOS 13, *) {
                return arg.latestStyleUpdateEnvironment.traitCollection
                    .hasDifferentColorAppearance(comparedTo: arg.newEnvironment.traitCollection)
            } else {
                return arg.userInterfaceStyleChanged
            }
        }
    }

    public struct Locale<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.propertyChanged(\.locale)
        }
    }

    public struct Theme<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.propertyChanged(\.theme)
        }
    }

    public struct ThemeOrUserInterfaceStyle<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            Theme.needUpdate(arg) || UserInterfaceStyle.needUpdate(arg)
        }
    }

    public struct LocaleOrThemeOrUserInterfaceStyle<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            Locale.needUpdate(arg) || Theme.needUpdate(arg) || UserInterfaceStyle.needUpdate(arg)
        }
    }
}
