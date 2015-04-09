%% @author xdinlin
%% @doc @todo Add description to ctemplate.


-module(ctemplate).
-compile(export_all).

%% ====================================================================
%% Internal functions
%% ====================================================================
start() -> 
	spawn(?MODULE, loop, []).

rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive 
		{Pid, Response} -> Response
	end.

loop(X) ->
	receive 
		Any -> 
			io:format("Received:~p~n", [Any]),
			loop(X)
	end.