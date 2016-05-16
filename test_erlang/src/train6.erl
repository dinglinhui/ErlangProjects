-module(train6).
-compile(export_all).

keysearch(Key, [{Key, Value}|_]) ->
	io:format("key is ~p, result is ~p~n", [Key, Value]),
	Value;
keysearch(Key, [_|T]) ->
	keysearch(Key, T);
keysearch(Key, _) ->
	io:format("key is ~p, result is ~p~n", [Key, undefined]),
	undefined.
