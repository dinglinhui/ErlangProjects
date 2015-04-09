%% @author xdinlin
%% @doc @todo Add description to my_fac_server.


-module(my_fac_server).

%% ====================================================================
%% API functions
%% ====================================================================
-export([loop/0]).


%% ====================================================================
%% Internal functions
%% ====================================================================

loop() -> 
	receive
		{From, {fac, N}} ->
			From ! {self(), fac(N)},
			loop();
		{become, Something} ->
			Something
	end.

fac(0) -> 1;
fac(N) -> N * fac(N-1).
