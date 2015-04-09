%% @author xdinlin
%% @doc @todo Add description to counter.


-module(counter).
-compile(export_all).
%% ====================================================================
%% API functions
%% ====================================================================
-export([]).



%% ====================================================================
%% Internal functions
%% ====================================================================
start()->spawn(counter, loop, [0]).

increment(Pid)->
    Pid ! {self(), increament}.

value(Pid)->
    Pid ! {self(), value},
    receive
        {Pid, Value} -> 
            Value
	end.

stop(Pid)->
    Pid ! {self(), stop}.

loop(Val)->
	receive
		{_From, increament} -> 
            loop(Val + 1);
        
 		{From, value} -> 
            From ! {self(), Val}, loop(Val);
        
        {_From, stop} -> 
            true;
        
        _Other -> 
            loop(Val)
	end.   
