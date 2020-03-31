import UIKit

/**
 Defines the requirement to the type that can decide should be a view updated after changing an environment or not.
 */
public protocol UpdateStyleStrategyType {
    /// Supported environment type
    associatedtype Environment: StyleEnvironmentType

    /**
     Receives the previous and the new environments and should return true if a view needs to be updated, false – otherwise.
     */
    static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool
}

public struct EnvironmentChange {
    /**
     The `UpdateStyleStrategyType` implementation. A view should be updated after any environment change.
     */
    public struct `Any`<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            true
        }
    }

    /**
     The `UpdateStyleStrategyType` implementation. A view should be updated if traitCollection changed.
     */
    public struct AnyTraitCollection<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.propertyChanged(\.traitCollection)
        }
    }

    /**
     The `UpdateStyleStrategyType` implementation. A view should be updated if appearance or content size category changed.
     */
    public struct UserInterfaceStyle<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            if arg.traitCollectionPropertyChanged(\.preferredContentSizeCategory) {
                return true
            }

            if #available(iOS 13, *) {
                return arg.latestStyleUpdateEnvironment.traitCollection
                    .hasDifferentColorAppearance(comparedTo: arg.newEnvironment.traitCollection)
            } else {
                return arg.userInterfaceStyleChanged
            }
        }
    }

    /**
     The `UpdateStyleStrategyType` implementation. A view should be updated if a locale changed.
     */
    public struct Locale<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.propertyChanged(\.locale)
        }
    }

    /**
     The `UpdateStyleStrategyType` implementation. A view should be updated if a theme changed.
     */
    public struct Theme<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            arg.propertyChanged(\.theme)
        }
    }

    /**
     The `UpdateStyleStrategyType` implementation. A view should be updated if the theme or appearance changed.
     */
    public struct ThemeOrUserInterfaceStyle<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            Theme.needUpdate(arg) || UserInterfaceStyle.needUpdate(arg)
        }
    }

    /**
     The `UpdateStyleStrategyType` implementation. A view should be updated if the locale or the theme or appearance changed.
     */
    public struct LocaleOrThemeOrUserInterfaceStyle<Environment: StyleEnvironmentType>: UpdateStyleStrategyType {
        public static func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
            Locale.needUpdate(arg) || Theme.needUpdate(arg) || UserInterfaceStyle.needUpdate(arg)
        }
    }
}
