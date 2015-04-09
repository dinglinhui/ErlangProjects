%% @author xdinlin
%% @doc @todo Add description to train01.


-module(train01).

%% ====================================================================
%% API functions
%% ====================================================================
-export([myLen/1, myTst/0]).



%% ====================================================================
%% Internal functions
%% ====================================================================
myTst() ->
	myLen([1,2,3,[[[[4],[]],[[[[5]]],[6,[7,[8]],9]],10]],[11],[[12],13]]).

myLen(L) -> 
	 getlen(L, 0).

%% getlen([H|T], Num) ->
%% 	io:format("Head ~p Tail ~p Num ~p ~n", [H, T, Num]),
%% 	case is_integer(H) of
%% 		true -> getlen(T, Num+1);
%% 		false -> case is_list(H) orelse is_tuple(H) of
%% 					true -> getlen(T, getlen(H, Num));
%% 					false -> getlen(T, Num)
%% 				 end
%% 	end;

getlen([H|T], Num) when is_list(H) orelse is_tuple(H) ->
    getlen(T, getlen(H, Num));

getlen([_H|T], Num) ->
	getlen(T, Num+1);

getlen([], Num) ->
	Num.
 