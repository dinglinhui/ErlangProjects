%% @author xdinlin
%% @doc @todo Add description to ctemplate.


-module(addressBook_client).
-compile(export_all).
%% -import(addressBook_server, [start/0]).

%% ====================================================================
%% Internal functions
%% ====================================================================
start() -> 
	Pidc = spawn(?MODULE, loop, [0]),
	test(Pidc, 0).

test(Pidc, X) ->
	Pids = addressBook_server:start(),
	Pids ! {Pidc, {times, X}},
	Pids ! {Pidc, {add, "kevin", "abc", 18662713988, "dinglinhui@hotmail.com"}},
	Pids ! {Pidc, {add, "allen", "abc", 18662713988, "dinglinhui@hotmail.com"}},
	Pids ! {Pidc, {add, "dinglinhui", "abc", 18662713988, "dinglinhui@hotmail.com"}},
	Pids ! {Pidc, {add, "ding", "abc", 18662713988, "dinglinhui@hotmail.com"}},
	Pids ! {Pidc, {add, "1234", "abc", 18662713988, "dinglinhui@hotmail.com"}},
	Pids ! {Pidc, {add, "linhui", "abc", 18662713988, "dinglinhui@hotmail.com"}}.

rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive 
		{Pid, Response} -> Response
	end.

loop(X) ->
	receive 
		{From, stop_more_record} ->
			case X >= 50 of 
				true -> 
					io:format("restart 50 times"),
					From ! {self(), stop};
				false -> 
					test(self(), X+1)
			end,
			loop(X+1);
		
		{_From, ok} ->
			loop(X);
			
		Any -> 
			io:format("Received:~p~n", [Any]),
			loop(X)
	end.