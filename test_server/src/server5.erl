%% @author xdinlin
%% @doc @todo Add description to server5.


-module(server5).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0, rpc/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================
start() -> spawn(fun() -> wait() end).

wait() -> 
	receive
		{become, F} -> F()
	end.

rpc(Pid, Q) ->
	Pid ! {self(), Q},
	receive
		{Pid, Reply} -> Reply
	end.

