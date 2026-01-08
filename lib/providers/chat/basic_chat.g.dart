// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_chat.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BasicChat)
const basicChatProvider = BasicChatProvider._();

final class BasicChatProvider
    extends $NotifierProvider<BasicChat, List<Message>> {
  const BasicChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'basicChatProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$basicChatHash();

  @$internal
  @override
  BasicChat create() => BasicChat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Message> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Message>>(value),
    );
  }
}

String _$basicChatHash() => r'e7bb1f28eb3beeade41e7bc2cc1de6681d8e1973';

abstract class _$BasicChat extends $Notifier<List<Message>> {
  List<Message> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Message>, List<Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Message>, List<Message>>,
              List<Message>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
