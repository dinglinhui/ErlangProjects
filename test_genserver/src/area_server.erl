%% @author xdinlin
%% @doc @todo Add description to area_server.


-module(area_server).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([area/1, start_link/0]).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

area(Thing) ->
	gen_server:call(?MODULE, {area, Thing}).

%% ====================================================================
%% Behavioural functions 
%% ====================================================================
init([]) ->
  %% 	attention: if you want to let terminate/2 be called when application stop, you must set trap_exit = true
	process_flag(trap_exit, true),
	io:format("~p starting~n", [?MODULE]),
    {ok, 0}.

handle_call({area, Thing}, _From, N) -> {reply, compute_area(Thing), N+1}.

handle_cast(_Msg, N) -> {noreply, N}.

handle_info(_Info, N) -> {noreply, N}.

terminate(_Reason, _N) ->
	io:format("~p stoping~n", [?MODULE]),
    ok.

code_change(_OldVsn, N, _Extra) -> {ok, N}.

compute_area({square, X}) 		-> X*X;
compute_area({rectangle, X, Y}) -> X*Y.


