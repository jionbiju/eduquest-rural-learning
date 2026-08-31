import 'dart:js_interop';

@JS('eduquestTts.speak')
external void _jsSpeak(
  JSString text,
  JSString locale,
  JSFunction? onEnd,
  JSFunction? onError,
);

@JS('eduquestTts.stop')
external void _jsStop();

void playWebTts(String text, String locale, void Function() onEnd, void Function(dynamic) onError) {
  _jsSpeak(
    text.toJS,
    locale.toJS,
    onEnd.toJS,
    ((JSAny? _) => onError(_)).toJS,
  );
}

void stopWebTts() {
  _jsStop();
}
