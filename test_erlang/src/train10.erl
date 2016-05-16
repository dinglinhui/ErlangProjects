-module(train10).
-compile(export_all).

start() ->
		register(?MODULE, spawn_opt(fun() -> ets:new(query_history, [named_table, public]), loop() end, [])).
	%%Pid = spawn_opt(fun() -> ets:new(query_history, [named_table, public]),
	%%				loop() end, []),
	%%erlang:register(?MODULE, Pid).
	
stop() -> ?MODULE ! stop.

loop() -> 
	receive
		{query, From, Customer, Year} ->
			Result = is_leap_year(Year),
			io:format("custmoer: ~p, year:~p, result: ~p~n", [Customer, Year, Result]),
			From ! Result,
			add_history(Customer, Year),
			loop();
		{history, From, Customer} ->
			Result = get_history(Customer),
			From ! Result,
			loop();
		stop ->
			stop
	end.

query(Customer, Year) -> 
	?MODULE ! {query, self(), Customer, Year},
	receive
		Msg -> 
			Msg
	end.
history(Customer) ->
	?MODULE ! {history, self(), Customer},
	receive
		Msg ->
			io:format("customer:~p, result:~p~n", [Customer,Msg]),
			Msg
	end.
add_history(Customer, Year) ->
	case ets:lookup(query_history, Customer) of
		[{Customer, Years}] ->
			NewYears = case lists:member(Year, Years) of
							true ->
									Years;
							_    ->
									[Year|Years]
		            	end,
		ets:update_element(query_history, Customer, {2, NewYears});
	_ ->
		ets:insert(query_history, {Customer, [Year]})
	end.

get_history(Customer) ->
	ets:lookup_element(query_history, Customer, 2).

is_leap_year(Year) when (Year rem 4 == 0),(Year rem 100 =/= 0); (Year rem 400 == 0) ->
	true;
is_leap_year(_) ->
	false. 
