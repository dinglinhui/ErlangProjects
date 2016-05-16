-module(train7).
-compile(export_all).

str_to_ipv4(Str) ->
	io:format("parameter = ~p~n", [Str]),
	Splits = re:split(Str, "[.]", [{return, list}]),
	do_str_to_ipv4(Splits).

do_str_to_ipv4([A, B, C, D]) ->
	A1 = list_to_integer(A),
	B1 = list_to_integer(B),
	C1 = list_to_integer(C),
	D1 = list_to_integer(D),
	case check(A1) andalso check(B1) andalso check(C1) andalso check(D1) of
		true  -> io:format("result = ~p~n", [{A1,B1,C1,D1}]),
				 {A1,B1,C1,D1};
		false -> io:format("result = {error, bad_fomat}~n"),
				 {error, bad_format}
		end;
do_str_to_ipv4(_) ->
		io:format("result = {error, bad_format}~n"),
		{error, bad_format}.

check(X) when X >= 0 andalso X < 256 ->
	true;
check(_) ->
	false.
