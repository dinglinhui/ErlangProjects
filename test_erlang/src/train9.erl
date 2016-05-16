-module(train9).
-compile(export_all).

is_leap_year(Int) when Int rem 4 == 0,Int rem 100 =/= 0; Int rem 400 == 0	
	 -> io:format("the ~p year is leap!~n", [Int]),
		true;
is_leap_year(Int) ->
	io:format("the ~p year is not leap!~n", [Int]),
	false.		
