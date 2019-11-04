import RxSwift

public struct EnvironmentRelay<Environment>: ObservableConvertibleType, ObserverType {
    private let replaySubject = ReplaySubject<Environment>.create(bufferSize: 1)

    public init() {
    }

    public func setEnvironment(_ environment: Environment) {
        replaySubject.onNext(environment)
    }

    public func asObservable() -> Observable<Environment> {
        replaySubject.asObservable()
    }

    public func on(_ event: Event<Environment>) {
        switch event {
        case let .next(env):
            replaySubject.onNext(env)

        default:
            break
        }
    }
}
