-module(train13).
-compile(export_all).

-record(state, {new_server, new_server_rest = 0, name_servers = dict:new()}).
-record(person, {name, address, phone, email}).

start() ->
	register(?MODULE, spawn(fun() -> erlang:process_flag(trap_exit, true), loop(#state{}) end, [])).

stop() ->
	?MODULE ! stop.
	
add(Name, Address, Phone, Email) ->
	?MODULE ! {add, self(), Name, Address, Phone, Email},
	wait_res().
	
do_add(From, Name, Address, Phone, Email, #state{new_server_rest = 0, name_servers = NameServers}) ->
	Pid = train13_:start_link(),
	Pid ! {add, self(), Name, Address, Phone, Email},
	receive
		ok ->
			From ! ok;
		{error, Reason} ->
			From ! {error, Reason}
	after
		30000 ->
		From ! {error, timerout}
	end,
	#state{new_server = Pid, new_server_rest = 4, name_servers = dict:store(Name, Pid, NameServers)};
	
do_add(From, Name, Address, Phone, Email, #state{new_server = Pid,
	new_server_rest = Rest} = State) ->
		Pid ! {add, self(), Name, Address, Phone, Email},
		receive
			ok ->	
				From ! ok;
			{error,Reason} ->
				From ! {error, Reason}
		after	
			30000 ->
				From ! {error, timeout}
		end,
		State#state{new_server_rest = Rest - 1}.
		
query(Name) ->
	?MODULE ! {query, self(), Name},
	wait_res().

do_query(From, Name, NameServers) ->
	case dict:find(Name, NameServers) of
		{ok, Pid} ->
			Pid ! {query, self(), Name},
			receive
				#person{} = Person ->
					From ! Person;
				{error, Reason} ->
					From ! {error, Reason}
			after
				30000 ->
					From ! {error, timeout}
			end;
		_ ->
			From ! {erro, not_exist}
	end.
	
reset() ->
	?MODULE ! {reset, self()}.
	
sum() ->
	?MODULE ! {sum, self()}.
	
modify(Name, Field, Value) ->
	?MODULE ! {modify, self(), Name, Field,	Value},
	wait_res().

do_modify(From, Name, Field, Value, NameServers) ->
	case dict:find(Name, NameServers) of
		{ok, Pid} ->
			Pid ! {query, self(), Name, Field, Value},
			receive
				ok ->
					From ! ok;
				{error, Reason} ->
					From ! {error, Reason}
			after
				30000 ->
					From ! {error, timeout}
			end;
		_ ->
			From ! {error, not_exist}
	end.

delete(Name) ->
	?MODULE ! {delete, self(), Name},
	wait_res().

do_delete(From, Name, #state{name_servers = NameServers} = State) ->
	case dict:find(Name, NameServers) of
		{ok, Pid} ->
			Pid ! {delete, self(), Name},
			receive
				ok ->
					From ! ok,
					State#state{name_servers = dict:erase(Name, NameServers)};
				{error, Reason} -> 
					From ! {error, Reason},
					State
			after
				30000 ->
					From ! {error, timeout},
					State
			end;
		_ ->
			From ! {error, not_exist},
			State
	end.
	
loop(#state{name_servers = NameServers} = State) ->
	receive
		{add, From, Name, Address, Phone, Email} ->
			NewState = do_add(From, Name, Address, Phone, Email, State),
			loop(NewState);
		{query, From, Name} ->
			do_query(From, Name, NameServers),
			loop(State);
		{modify, From, Name, Field, Value} ->
			do_modify(From, Name, Field, Value, NameServers),
			loop(State);
		{delete, From, Name} -> 
			NewState = do_delete(From, Name, State),
			loop(NewState);
		{reset, From} ->
			From ! ok,
			timer:apply_after(1000, ?MODULE, start, []),
			ok;
		{sum, From} -> 
			Size = dict:size(NameServers),
			From ! Size,
			loop(State);
		{'DOWN', Pid, _Reason} ->
			NewNameServers = dict:fold(fun (_, Value, Acc0) when Value == Pid -> 
									Acc0;
								(Key, Value, Acc0) -> 
									dict:store(Key, Value, Acc0)
								end, dict:new(), NameServers),
			loop(State#state{name_servers = NewNameServers});
		stop ->
			stop;
		{server_stop, List} ->  % for train14
			lists:foreach(fun({Key, Value}) -> put(Key, Value) end, List),
			loop(State);
		_ ->
			loop(State)
	end.
	
	wait_res() ->
		receive
			Msg	->
				Msg
		end.