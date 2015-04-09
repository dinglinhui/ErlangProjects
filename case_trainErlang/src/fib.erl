%% @author xdinlin
%% @doc @todo Add description to fib.


-module(fib).
-export([fib/1, err/1]).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").

%% ====================================================================
%% Internal functions
%% ====================================================================


fib(0) -> 1;
fib(1) -> 1;
fib(N) when N > 1 -> fib(N-1) + fib(N-2).
 
err([])->
    [];
err(T) ->
    {error, T}.

fib1_test() ->
    [
     ?_assert(err(0) =:= {error, 10})].
 
fib_test_() ->
    [
     ?_assert(err(0) =:= {error, 10}),
     ?_assert(err([]) =:= []),
     ?_assert(fib(0) =:= 1),
     ?_assert(fib(1) =:= 1),
     ?_assert(fib(2) =:= 2),
     ?_assert(fib(3) =:= 3),
     ?_assert(fib(4) =:= 5),
     ?_assert(fib(5) =:= 8),
     ?_assertException(error, function_clause, fib(-1)),
     ?_assert(fib(31) =:= 2178309)
    ].


%% [4,3,2,1]=erlangpro:reverse([1,2,3,4]).
%% {[1,2],[b,d],["a","c"]}=erlangpro:group([1,"a",2,b,"c",d]).
%% 4= erlangpro:match([{high, 4},{width,6},{weight,16}],high).
%% 6=erlangpro:match([{high, 4},{width,6},{weight,16}],width).
%% undefined=erlangpro:match([{high, 4},{width,6},{weight,16}],width1).

