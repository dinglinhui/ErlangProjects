%% @author xdinlin
%% @doc @todo Add description to ets_test.


-module(ets_test).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0]).



%% ====================================================================
%% Internal functions
%% ====================================================================

start() ->
	lists:foreach(fun test_ets/1, 
				  [set, ordered_set, bag, duplicate_bag]).

test_ets(Mode) ->
	TableId = ets:new(test, [Mode]),
	ets:insert(TableId, {[a,c], [1,2,4]}),
	ets:insert(TableId, {b, 2}),
	ets:insert(TableId, {a, 1}),
	ets:insert(TableId, {a, 3}),
%% 	Look = ets:lookup(TableId, {a, 1}),
	List = ets:tab2list(TableId),
%% 	io:format("~p~n", [Look]),
	io:format("~-13w => ~p~n", [Mode, List]),
	ets:delete(TableId).

