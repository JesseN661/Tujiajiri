// Counter keeps ids unique even if two are made in the same microsecond.
int _counter = 0;

/// New id for an education or experience entry (it becomes the document id).
String newEntryId() => '${DateTime.now().microsecondsSinceEpoch}-${_counter++}';
