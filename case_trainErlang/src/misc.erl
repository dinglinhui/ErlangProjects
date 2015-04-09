%% @author xdinlin
%% @doc @todo Add description to remove.


-module(misc).

%% ====================================================================
%% API functions
%% ====================================================================
-export([odds_and_evens2/1]).



%% ====================================================================
%% Internal functions
%% ====================================================================
odds_and_evens2(L) ->
	odds_and_evens_acc(L, [], []). 
	
odds_and_evens_acc([H|T], Odds, Evens) ->
	case (H rem 2) of 
		1 -> 
            odds_and_evens_acc(T, [H|Odds], Evens); 
		0 -> 
            odds_and_evens_acc(T, Odds, [H|Evens])
	end; 

odds_and_evens_acc([], Odds, Evens) ->
	{Odds, Evens}. 
