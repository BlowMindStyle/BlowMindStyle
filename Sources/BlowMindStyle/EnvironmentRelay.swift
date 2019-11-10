import RxSwift

public final class EnvironmentRelay<Environment>: ObservableConvertibleType {
    private let replaySubject = ReplaySubject<Environment>.create(bufferSize: 1)

    public init() {
    }

    public func setEnvironment(_ environment: Environment) {
        replaySubject.onNext(environment)
    }

    public func asObservable() -> Observable<Environment> {
        replaySubject.asObservable()
    }

    public func accept(_ environment: Environment) {
        replaySubject.onNext(environment)
    }
}
