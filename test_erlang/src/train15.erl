-module(train15).
-behaviour(gen_server).
-compile(export_all).
-record(state, {}).
-include_lib("stdlib/include/qlc.hrl").

start() ->
	gen_server:start({local, ?MODULE}, ?MODULE, [], []).

stop() ->
	gen_server:call(?MODULE, stop).
	
init([]) ->
	ets:new(web_page, [named_table, public, duplicate_bag]),
	{ok, #state{}}.
	
handle_call({add, Link, Key}, _From, State) ->
	do_add(Key, Link),
	{reply, ok, State};
handle_call({search, Keys}, _From, State) ->
	{reply, do_search(Keys), State};
handle_call(_Request, _From, State) ->
	Reply = ok,
	{reply, Reply, State}.
	
handle_cast(_Msg, State) ->
	{noreply, State}.
	
handle_info(_Info, State) ->
	{noreply, State}.
	
terminate(_Reason, _State) ->
	ok.
	
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
	
do_add(Key, Value) ->
	io:format("add record:~p~n", [{Key, Value}]),
	ets:insert(web_page, {Key,Value}).
	
do_search(Keys) ->
	Q = qlc:q([Y || {X, Y} <- ets:table(web_page), Key <- Keys, re:run(X, Key) =/= nomatch]),
	R = do(Q),
	io:format("parameter:~p, search result: ~p~n", [Keys, R]),
	R.
	
add(Link, Keys) ->
	gen_server:call(?MODULE, {add, Link, Keys}).
	
search(Keys) ->
	gen_server:call(?MODULE, {search, Keys}).
	
do(Q) ->
	qlc:e(Q).