%% @author xdinlin
%% @doc @todo Add description to addressBook.

-module(addressBook_server).
-compile(export_all).
%% ====================================================================
%% API functions
%% ====================================================================
%% -export([start/0, loop/1, rpc/2, test/1]).

-record(person, {
				 	name, 
					address, 
					phone_number, 
					email
				 }).

%% ====================================================================
%% Internal functions
%% ====================================================================
start() -> spawn(?MODULE, loop, [[]]).

%% Pid = addressBook:start().
%% addressBook:rpc(Pid, {add, "kevin", "abc", 18662713988, "dinglinhui@hotmail.com"}).
%% addressBook:rpc(Pid, {add, "allen", "abc", 18662713988, "dinglinhui@hotmail.com"}).
%% addressBook:rpc(Pid, {add, "dinglinhui", "abc", 18662713988, "dinglinhui@hotmail.com"}).
%% addressBook:rpc(Pid, {add, "ding", "abc", 18662713988, "dinglinhui@hotmail.com"}).
%% addressBook:rpc(Pid, {add, "linhui", "abc", 18662713988, "dinglinhui@hotmail.com"}).
%% addressBook:rpc(Pid, {query, "allen"}).
%% addressBook:rpc(Pid, {modify, "allen", {phone_number, 15221657056}}).
%% addressBook:rpc(Pid, {delete, "ding"}).
%% addressBook:rpc(Pid, sum).
%% addressBook:rpc(Pid, reset).
%% addressBook:rpc(Pid, stop).
rpc(Pid, Request) ->
	Pid ! {self(), Request},
	receive 
		{Pid, Response} -> 
			io:format("addressBook_server rpc"), 
			Response
	end.

flush() ->
    receive 
        _ -> flush()
    after
        0 -> ok
    end.

loop(AddressBook) ->
	receive 
		{From, {add, Name, Address, Phone_number, Email}} -> 
			case sum(AddressBook) >= 5 of
				true -> 
					io:format("I can't hold any more!~n"), 
					From ! {self(), stop_more_record};
				false -> 
					AddressUpdate = [#person{name = Name, address = Address, phone_number = Phone_number, email = Email}|AddressBook],
					From ! {self(), ok}, 
					loop(AddressUpdate)
			end;

		{From, {query, Name}} -> 
			Record = query(AddressBook, Name),
  			From ! {self(), Record}, 
			loop(AddressBook);

		{From, {modify, Name, {Field, Value}}} -> 
			AddressModify = modify(AddressBook, Name, {Field, Value}, []),
			io:format("~n~p~n", [AddressModify]),
  			From ! {self(), ok}, 
			loop(AddressModify);

		{From, {delete, Name}} -> 
			AddressDelete = delete(AddressBook, Name, []),
			io:format("~n~p~n", [AddressDelete]),
  			From ! {self(), ok}, 
			loop(AddressDelete);

		{From, reset} -> 
			io:format("Reset ~n"),
  			From ! {self(), ok}, 
			loop([]);

		{From, sum} -> 
			Num = sum(AddressBook),
			io:format("Sum ~p~n", [Num]),
  			From ! {self(), Num}, 
			loop(AddressBook);
		
		{_From, {times, Times}} ->
			io:format("start ~p~n", [Times]),
			loop(AddressBook);

		{From, stop} ->
			From ! {self(), stop_command};
			
		{From, Other} -> 
			From ! {self(), {error, Other}}, 
			loop(AddressBook)
	end.

%%  ====================================================================
%% add(Name, Address, Phone_number, Email). return ok|{error, Reason}
%%  ====================================================================
add([_H|_T], Name, Address, Phone_number, Email) ->
	#person{name = Name, address = Address, phone_number = Phone_number, email = Email}.

%%  ====================================================================
%% %% query(Name), return #person|{error, Reason}.
%%  ====================================================================
query([H|T], Name) when is_record(H, person)->
	case H#person.name =:= Name of
		true -> H#person{};
		false -> query(T, Name)
	end;

query([_H|_T], _Name) ->
	{error, not_recode};

query([], _Name) ->
	{error, no_find}.

%%  ====================================================================
%% %% modify(Name,{Field, Value}), return ok|{error, Reason}.  
%%  ====================================================================
    
modify([H|T], Name, {Field, Value}, AddressModify) when is_record(H, person)->
    case H#person.name =:= Name of
		true -> 
			[_Head|PersonValue] = tuple_to_list(H#person{}), 
			PersonMap = lists:zipwith(fun(X, Y) -> {X, Y} end, record_info(fields, person), PersonValue),
			NewRecord = list_to_tuple([person|updateRecord(PersonMap, {Field, Value}, [])]),
			modify(T, Name, {Field, Value}, [NewRecord|AddressModify]);
		false -> 
            modify(T, Name, {Field, Value}, [H|AddressModify])
    end;

modify([_H|_T], _Name, {_Field, _Value}, _AddressModify) ->
	{error, not_recode};

modify([], _Name, {_Field, _Value}, AddressModify) ->
	lists:reverse(AddressModify).

updateRecord([{F, V}|T], {Field, Value}, NewRecord) ->
	case Field =:= F of
		true -> updateRecord(T, {Field, Value}, [Value|NewRecord]);
		false -> updateRecord(T, {Field, Value}, [V|NewRecord])
	end;

updateRecord([], {_Field, _Value}, NewRecord) ->
	lists:reverse(NewRecord).

%%  ====================================================================
%% %% delete(Name), return ok|{error, Reason}.
%%  ====================================================================
delete([H|T], Name, AddressDelete) ->
	case is_record(H, person)  of
		true -> case H#person.name =:= Name of
					true -> delete(T, Name, AddressDelete);
					false -> delete(T, Name, [H|AddressDelete])
				end;
		false -> {error, not_recode}
	end;

delete([], _Name, AddressDelete) ->
	lists:reverse(AddressDelete).

%%  ====================================================================
%% %% reset(), reset the server, all data & state is clear.
%%  ====================================================================
reset([_H|_T]) -> 
	ok.

%%  ====================================================================
%% %% sum(), return the number of records. return Int.
%%  ====================================================================
sum(AddressBook) ->
	sum(AddressBook, 0).

sum([_H|T], Num) ->
	sum(T, Num+1);

sum([], Num) -> 
	Num.
