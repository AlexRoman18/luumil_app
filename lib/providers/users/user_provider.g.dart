// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geminiUser)
const geminiUserProvider = GeminiUserProvider._();

final class GeminiUserProvider
    extends $FunctionalProvider<types.User, types.User, types.User>
    with $Provider<types.User> {
  const GeminiUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiUserHash();

  @$internal
  @override
  $ProviderElement<types.User> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  types.User create(Ref ref) {
    return geminiUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(types.User value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<types.User>(value),
    );
  }
}

String _$geminiUserHash() => r'0b245ddf6f54fd3569f316a9cc65233545db7f81';

@ProviderFor(user)
const userProvider = UserProvider._();

final class UserProvider
    extends $FunctionalProvider<types.User, types.User, types.User>
    with $Provider<types.User> {
  const UserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userHash();

  @$internal
  @override
  $ProviderElement<types.User> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  types.User create(Ref ref) {
    return user(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(types.User value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<types.User>(value),
    );
  }
}

String _$userHash() => r'31ff84d91fa037c7cd278824b7dd29406718ab7a';
