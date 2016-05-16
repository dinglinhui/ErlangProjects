-module(train4).
-compile(export_all).

myreverse(L) -> 
	myreverse(L,[]).
myreverse([H|T], List) ->
	myreverse(T,[H|List]);
myreverse([], List) ->
	List.
