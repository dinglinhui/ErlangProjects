%% @author xdinlin
%% @doc @todo Add description to engine.


-module(engine).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-compile(export_all).

start() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()	-> gen_server:call(?MODULE, stop).

add(Link, Keys)	-> gen_server:call(?MODULE, {add, Link, Keys}).
search(Keys)	-> gen_server:call(?MODULE, {search, Keys}).

test() -> 
	engine:start(),
	engine:add(["www.baidu.com"], ["baidu", "bai"]),
	engine:add(["www.google.com"], ["goo", "google"]),
	engine:add(["www.sport.com"], ["sport", "spor"]),
	engine:add(["www.oracle.com"], ["ora", "oracle"]),
	engine:search(["baidu", "goo", "SPORT", "le"]),
	engine:stop().
	
%% ====================================================================
%% Behavioural functions 
%% ====================================================================

%% init/1
init([]) -> {ok, ets:new(?MODULE, [set])}.

%% handle_call/3
handle_call({add, Link, Keys}, _From, TableId) ->
	Reply = {add, Link, Keys, ets:insert(TableId, {Link, Keys})},
%% 	io:format("~p~n", [ets:lookup(TableId, Link)]),
%% 	io:format("~p~n", [ets:tab2list(TableId)]),
	{reply, Reply, TableId};

handle_call({search, Keys}, _From, TableId) ->
	Reply = {search, Keys, search_key(ets:tab2list(TableId), Keys, [])},
	{reply, Reply, TableId};

handle_call(stop, _From, TableId) ->
	ets:delete(TableId),
	{stop, normal, stopped, TableId}.

handle_cast(_Msg, State) -> 
    {noreply, State}.

handle_info(_Info, State) -> 
    {noreply, State}.

terminate(_Reason, _State) -> 
    ok.

code_change(_OldVsn, State, _Extra) -> 
    {ok, State}.

%% ====================================================================
search_key(TabList, [H|T], Links) ->
%% 	io:format("search_key1 Head ~p Tail ~p Links ~p ~n", [H, T, Links]),
	search_key(TabList, T, [search_key(TabList, H)|Links]);
	
search_key(_TabList, [], Links) ->
	lists:reverse(Links).

search_key([H|T], Key) ->
%% 	io:format("search_key Head ~p Tail ~p Key ~p ~n", [H, T, Key]),
	case match_key(element(2, H), string:to_lower(Key)) of
		true -> 
            [element(1, H)|search_key(T, Key)];
		false -> 
            search_key(T, Key)
	end;

search_key([], _Key) ->
	[].

match_key([H|T], Key) ->
%% 	io:format("match_key Head ~p Tail ~p Key ~p ~n", [H, T, Key]),
	case string:str(H, Key) of
		0 -> 
            match_key(T, Key);
		_ -> 
            true
	end;

match_key([], _Key) ->
	false.
