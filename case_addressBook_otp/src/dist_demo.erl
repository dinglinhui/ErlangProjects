%% @author xdinlin
%% @doc @todo Add description to dist_demo.


-module(dist_demo).

%% ====================================================================
%% API functions
%% ====================================================================
-export([rpc/4, start/1]).



%% ====================================================================
%% Internal functions
%% ====================================================================
start(Node) ->
	spawn(Node, fun() -> loop() end).

rpc(Pid, M, F, A) ->
	Pid ! {rpc, self(), M, F, A},
	receive 
		{Pid, Response} ->
			Response
	end.

loop() -> 
	receive
		{rpc, Pid, M, F, A} ->
			Pid ! {self(), (catch apply(M, F, A))},
			loop()
	end.

