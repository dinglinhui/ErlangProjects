-module(train2).
-compile(export_all).

getstr([H|[]]) -> [H];
getstr([])     -> [];
getstr([H|T])  ->
	case (H == $<) of
		true  -> getstr2(lists:reverse(T));
		false -> [H|T]
	end.

getstr2([H|T]) ->
	case (H == $>) of
		true  -> lists:reverse(T);
		false -> "<" ++ lists:reverse([H|T])
	end.


