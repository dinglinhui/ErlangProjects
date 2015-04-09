%% @author xdinlin
%% @doc @todo Add description to server1.


-module(server1).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/2, rpc/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================
start(Name, Mod) ->
	register(Name, spawn(fun() -> loop(Name, Mod, Mod:init()) end)).

rpc(Name, Request) ->
	Name ! {self(), Request},
	receive 
		{Name, Response} -> Response
	end.

loop(Name, Mod, State) ->
	receive 
		{From, Request} ->
			{Response, State1} = Mod:handle(Request, State),
			From ! {Name, Response},
			loop(Name, Mod, State1)
	end.

