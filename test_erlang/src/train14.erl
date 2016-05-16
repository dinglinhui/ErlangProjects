-module(train14).
-compile(export_all).

-record(person, {name, address, phone, email}).
-record(state, {persons = dict:new()}).

start_link() ->
	spawn_opt(fun() -> loop(#state{}) end, [link]).

stop(Pid) ->
	Pid ! stop.
	
loop(#state{persons = Persons} = State) ->
	receive
		{add, From, Name, Address, Phone, Email} ->
			case do_add(Name, Address, Phone, Email, Persons) of
				{ok, Person} ->
					From ! ok,
					loop(#state{persons = dict:store(Name, Person, Persons)});
				{error, overload} ->
					io:format("I can't hold any more!"),
					From ! {error, overload};
				Error ->
					From ! Error,
					loop(State)
			end;
		{query, From, Name} -> 
			case dict:find(Name, Persons) of	
				{ok, Person} ->
					From ! Person;
				_ ->
					From ! {error, not_exist}
			end,
			loop(State);
		{modify, From, Name, Field, Value} ->
			case do_modify(Name, Field, Value, Persons) of
				{ok, Person} ->
					From ! ok,
					loop(#state{persons = dict:store(Name, Person, Persons)});
				Err ->
					From ! Err,
					loop(State)
			end;
		{delete, From, Name} ->
			case dict:is_key(Name, Persons) of
				true -> 
					From ! ok,
					loop(#state{persons = dict:erase(Name, Persons)});
				_ ->
					From ! {error, not_exist},
					loop(State)
			end;
		{reset, From} ->
			From ! ok,
			loop(#state{});
		{sum, From} ->
			Size = dict:size(Persons),
			From ! Size,
			loop(State);
		stop ->
			%for the train14
			catch train13 ! {server_stop, dict:to_list(Persons)},
			stop;
		_ ->
			loop(State)
	end.
	
do_add(Name, Address, Phone, Email, Persons) ->
	case dict:size(Persons) > 4 of
		true ->
			{error, overload};
		_ ->
			case dict:is_key(Name, Persons) of
				false ->
					{ok, #person{name = Name, address = Address, phone = Phone, email = Email}};
				_ ->
					{error, already_exist}
				end
	end.
		
do_modify(Name, Field, Value, Person) ->
	case dict:find(Name, Person) of
		{ok, Person} ->	
			update_field(Person, Field, Value);
		_ ->
			{error, not_exist}
	end.

update_field(Person, name, Value) ->
	{ok, Person#person{name = Value}};
update_field(Person, address, Value) ->
	{ok, Person#person{address = Value}};
update_field(Person, phone, Value) ->	
	{ok, Person#person{phone = Value}};
update_field(Person, email, Value) ->
	{ok, Person#person{email = Value}};
update_field(_, _, _) ->
	{error, not_exist_field}.
	
