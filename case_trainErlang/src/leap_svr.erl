%% @author xdinlin
%% @doc @todo Add description to leap_svr.


-module(leap_svr).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0, loop/1, rpc/2]).
 

%% ====================================================================
%% Internal functions
%% ====================================================================
start() -> spawn(leap_svr, loop, [[]]).

rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive 
		{Pid, Response} -> Response
	end.

loop(YearRecord) ->
	receive 
		{From, {isLeapYear, Year}} -> 
            From ! {self(), is_leap_year(Year)}, loop([Year|YearRecord]);
		{From, queryHisoty} -> 
            From ! {self(), lists:reverse(YearRecord)}, loop(YearRecord);
		{From, Other} -> 
            From ! {self(), {error, Other}}, loop(YearRecord)
	end.

is_leap_year(Year) when is_integer(Year) andalso Year >= 0 ->
	case (Year rem 4 =:= 0 andalso Year rem 100 /= 0) orelse (Year rem 400 =:= 0) of 
		true -> true;
		false -> false
	end;

is_leap_year(_Year) ->
    false.