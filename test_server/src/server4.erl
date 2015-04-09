%% @author xdinlin
%% @doc @todo Add description to server2.


-module(server4).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/2, rpc/2, swap_code/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================
start(Name, Mod) ->
	register(Name, spawn(fun() -> loop(Name, Mod, Mod:init()) end)).

swap_code(Name, Mod) -> rpc(Name, {swap_code, Mod}).

rpc(Name, Request) ->
	Name ! {self(), Request},
	receive
		{Name, crash} -> exit(rpc);
		{Name, ok, Response} -> Response
	end.

loop(Name, Mod, OldState) ->
	receive
		{From, {swap_code, NewCallBackMod}} ->
			From ! {Name, ok, ack},
			loop(Name, NewCallBackMod, OldState);
		{From, Request} ->
			try Mod:handle(Request, OldState) of
				{Response, NewState} ->
					From ! {Name, ok, Response},
					loop(Name, Mod, NewState)
			catch
				_:Why ->
					log_the_error(Name, Request, Why),
					%% Send a message to crash client.
					From ! {Name, crash},
					%% loop with initialization state.
					loop(Name, Mod, OldState)
			end
	end.

log_the_error(Name, Request, Why) ->	
	io:format("Server ~p request ~p ~n"
			 "caused exception ~p~n",
			 [Name, Request, Why]).
	
	