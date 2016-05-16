-module(train5).
-compile(export_all).

split(L) -> 
	split(L, [], [], []).

split([H|T], Atom, Int, Str) when is_atom(H) ->
	split(T, [H|Atom], Int, Str);
split([H|T], Atom, Int, Str) when is_integer(H) ->
	split(T, Atom, [H|Int], Str);
split([H|T], Atom, Int, Str) when is_list(H) ->
	split(T, Atom, Int, [H|Str]);

split([], List1, List2, List3) ->
	 [lists:reverse(List1), lists:reverse(List2), lists:reverse(List3)].
