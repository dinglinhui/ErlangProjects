-module(train8).
-compile(export_all).

split(Str) ->
	List = string:tokens(Str, ", !"),
	io:format("parameter:~p, result:~p~n", [Str, List]),
	List.
