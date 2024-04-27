


import '../../base.dart';

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    '[${provider.name ?? provider.runtimeType.toString()}] expose: $newValue'
        .i();
  }

  @override
  void didAddProvider(ProviderBase<Object?> provider, Object? value,
      ProviderContainer container) {
    super.didAddProvider(provider, value, container);
    '[${provider.name ?? provider.runtimeType.toString()}] created: $value'.i();
  }

  @override
  void didDisposeProvider(
      ProviderBase<Object?> provider, ProviderContainer container) {
    super.didDisposeProvider(provider, container);
    '[${provider.name ?? provider.runtimeType.toString()}] disposed'.i();
  }

  @override
  void providerDidFail(ProviderBase<Object?> provider, Object error,
      StackTrace stackTrace, ProviderContainer container) {
    super.providerDidFail(provider, error, stackTrace, container);
    '[${provider.name ?? provider.runtimeType.toString()}] error: $error'.e();
  }
}
