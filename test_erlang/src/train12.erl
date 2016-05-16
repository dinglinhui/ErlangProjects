-module(train12).
-compile(export_all).

start() ->
	register(?MODULE, spawn_opt(fun() -> Ref = erlang:monitor(process, train11), loop(Ref) end, [])).

stop() ->
	?MODULE ! stop.

loop(MonitorRef) ->
	receive
		{'DOWN', MonitorRef, process, _, Error} ->
			erlang:demonitor(MonitorRef),
			io:format("process: train11 had down, reason:~p~n", [Error]),
			{Time, _} = timer:tc(train11, start, []),
			NewMonitorRef = erlang:monitor(process, train11),
			io:format("restart train11 cost ~p microseconds ~n", [Time]),
			loop(NewMonitorRef);
		stop -> 
			ok;
		Others ->
			io:format("received unexpected message: ~p~n", [Others]),
			loop(MonitorRef)
	end.
