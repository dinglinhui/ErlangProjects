%% @author xdinlin
%% @doc @todo Add description to addressBook.


-module(abserver).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0, stop/0, add/4, modify/2, delete/1, query/1, reset/0, sum/0, select_person/0]).
-include_lib("stdlib/include/qlc.hrl").

start() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()	-> gen_server:call(?MODULE, stop).

add(Name, Address, Phone_number, Email) -> gen_server:call(?MODULE, {add, Name, Address, Phone_number, Email}).
modify(Name, {Field, Value})			-> gen_server:call(?MODULE, {modify, Name, {Field, Value}}).
delete(Name)							-> gen_server:call(?MODULE, {delete, Name}).
query(Name)								-> gen_server:call(?MODULE, {query, Name}).
select_person()							-> gen_server:call(?MODULE, select_person).
reset()									-> gen_server:call(?MODULE, reset).
sum()									-> gen_server:call(?MODULE, sum).

%% ====================================================================
%% Behavioural functions 
%% ====================================================================
-record(state, {}).
-record(person, {
				 	name, 
					address, 
					phone_number, 
					email
				 }).

%% init/1
init([]) ->
%% 	process_flag(trap_exit, true),
%% 	io:format("~p starting, ~p~n", [?MODULE, self()]),
%% 	start mnesia
	case mnesia_lib:is_running() of
		yes -> 
            io:format("mnesia is running ~n");
		_ -> 
			mnesia:start(),
			mnesia:create_schema([node()]),
%% 			mnesia:create_schema(["kevin@E7B499BAF06C44.ericsson.se", "allen@E7B499BAF06C44.ericsson.se"]),
			case mnesia:create_table(person, [{type, ordered_set}, {attributes, record_info(fields, person)}, {disc_copies, []}]) of
				{atomic, ok} -> 
                    {atomic, ok};
				{error, Reason} -> 
                    io:format("create table error ~p~n", [Reason])
			end
	end,
%% 	start gen_tcp
%% 	{ok, ListenSocket} = gen_tcp:listen(1234, [binary, {reuseaddr, true}, {active, false}]),
%% 	register(abserver, spawn(?MODULE, server_loop, [ListenSocket, 0])), 
    {ok, #state{}}.

%% handle_call/3
handle_call({add, Name, Address, Phone_number, Email}, _From, TableId) ->
	Row = #person{name = Name, address = Address, phone_number = Phone_number, email = Email},
	F = fun() -> 
                mnesia:write(Row) end,
	Reply = mnesia:transaction(F),
	{reply, Reply, TableId};

handle_call({modify, Name, {Field, Value}}, _From, TableId) ->
	Oid = {person, Name},
    F = fun() -> 
			PersonList = update(mnesia:read({person, Name}), {Field, Value}, []),
			mnesia:delete(Oid),
			[mnesia:write(X#person{}) || X <- PersonList]
		end,
    Reply = mnesia:transaction(F),
	{reply, Reply, TableId};

handle_call({delete, Name}, _From, TableId) ->
	Oid = {person, Name},
    F = fun() -> mnesia:delete(Oid) end,
    Reply = mnesia:transaction(F),
	{reply, Reply, TableId};

handle_call(select_person, _From, TableId)  ->
	Reply = do(qlc:q([X || X <- mnesia:table(person)])),
	{reply, Reply, TableId};

handle_call({query, Name}, _From, TableId) ->
	F = fun() -> mnesia:read({person, Name}) end,
    Reply = mnesia:transaction(F),
	{reply, Reply, TableId};

handle_call(reset, _From, TableId) ->
    Reply = mnesia:clear_table(person),
	{reply, Reply, TableId};

handle_call(sum, _From, TableId) ->
	F = fun() -> 
		sum(mnesia:table(person))
	end,
    Reply = mnesia:transaction(F),
	{reply, Reply, TableId};

handle_call(stop, _From, TableId) ->
	{stop, normal, stopped, TableId}.

%% handle_cast/2
handle_cast(_Msg, State) ->
    {noreply, State}.

%% handle_info/2
handle_info(_Info, State) ->
    {noreply, State}.

%% terminate/2
terminate(_Reason, _State) ->
    ok.

%% code_change/3
code_change(_OldVsn, State, Extra) ->
    {ok, State}.

%% 
server_loop(ListenSocket, Count) ->
	% 阻塞，等待连接
	receive
		{quit} ->
			io:format("abserver will stop~n"),
			gen_tcp:close(ListenSocket);
		{'EXIT', Pid, Reason } ->
			io:format("Child ~p ~p exit~n", [Pid, Reason]),
			server_loop(ListenSocket, Count);
		_ -> true
	after 10 -> 
		 case gen_tcp:accept(ListenSocket, 3000) of
		 	{ok, Socket} ->
				% 创建进程?
				spawn(?MODULE, handle_connect, [Socket, [], Count]),
				server_loop(ListenSocket, Count+1);
			{error, timeout} ->
				server_loop(ListenSocket, Count);
			{error, Reason} ->
				io:format("accept failed ~p~n", [Reason]),
				gen_tcp:close(ListenSocket)
		end
	end.

%% 
handle_connect(Socket, BinaryList, Count) ->
	io:format("handle_connect ~p~n", [self()]),	
	case gen_tcp:recv(Socket, 0) of
		{ok, Binary} ->
			% 继续接收数据
			case gen_tcp:send(Socket, Binary) of
				ok ->
					handle_connect(Socket, BinaryList, Count);
				{error, Reason} -> 
					io:format("send failed~n"),
					gen_tcp:close(Socket)
			end;
		{error, timeout} ->
			io:format("recv timeout~n"),
			gen_tcp:close(Socket);
		{error, closed} ->
			% 直到对端关闭
			io:format("peer closed~n"),
			gen_tcp:close(Socket)
	end.

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    mnesia:transaction(F).

update([H|T], {Field, Value}, PersonList) ->
	case is_record(H, person)  of
		true -> 
			[_Head|PersonValue] = tuple_to_list(H#person{}), 
			PersonMap = lists:zipwith(fun(X, Y) -> {X, Y} end, record_info(fields, person), PersonValue),
			NewRecord = list_to_tuple([person|updateRecord(PersonMap, {Field, Value}, [])]),
			update(T, {Field, Value}, [NewRecord|PersonList]);
		false -> {error, not_recode}
	end;
update([], {_Field, _Value}, PersonList) ->
	lists:reverse(PersonList).
%%  ====================================================================
%% %% query(Name), return #person|{error, Reason}.
%%  ====================================================================
query([H|T], Name) ->
	case is_record(H, person)  of
		true -> case H#person.name =:= Name of
					true -> H#person{};
					false -> query(T, Name)
				end;
		false -> {error, not_recode}
	end;

query([], Name) ->
	{error, no_find}.

%%  ====================================================================
%% %% modify(Name,{Field, Value}), return ok|{error, Reason}.  
%%  ====================================================================
modify([H|T], Name, {Field, Value}, AddressModify) ->
%% 	io:format("H ~p T ~p Name ~p Field ~p Value ~p AddressModify ~p ~n", [H, T, Name, Field, Value, AddressModify]),
	case is_record(H, person)  of
		true -> case H#person.name =:= Name of
					true -> 
						[Head|PersonValue] = tuple_to_list(H#person{}), 
						PersonMap = lists:zipwith(fun(X, Y) -> {X, Y} end, record_info(fields, person), PersonValue),
						NewRecord = list_to_tuple([person|updateRecord(PersonMap, {Field, Value}, [])]),
						modify(T, Name, {Field, Value}, [NewRecord|AddressModify]);
					false -> modify(T, Name, {Field, Value}, [H|AddressModify])
				end;
		false -> {error, not_recode}
	end;

modify([], Name, {Field, Value}, AddressModify) ->
	lists:reverse(AddressModify).

updateRecord([{F, V}|T], {Field, Value}, NewRecord) ->
	case Field =:= F of
		true -> updateRecord(T, {Field, Value}, [Value|NewRecord]);
		false -> updateRecord(T, {Field, Value}, [V|NewRecord])
	end;

updateRecord([], {Field, Value}, NewRecord) ->
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

delete([], Name, AddressDelete) ->
	lists:reverse(AddressDelete).

%%  ====================================================================
%% %% reset(), reset the server, all data & state is clear.
%%  ====================================================================
reset([H|T]) -> 
	ok.

%%  ====================================================================
%% %% sum(), return the number of records. return Int.
%%  ====================================================================
sum(AddressBook) ->
	sum(AddressBook, 0).

sum([H|T], Num) ->
	sum(T, Num+1);

sum([], Num) -> 
	Num.

