-module(es2).
-behavior(gen_server).

-export([start_link/0, stop/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([server_loop/2, handle_connect/3]).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
	gen_server:cast(?MODULE, stop).

init([]) ->
	process_flag(trap_exit, true),
	io:format("~p starting, ~p~n", [?MODULE, self()]),
	{ok, ListenSocket} = gen_tcp:listen(1234, [binary, {reuseaddr, true}, {active, false}]),
	register(echoserver, spawn(?MODULE, server_loop, [ListenSocket, 0])), 
	{ok, 0}.

terminate(_Reason, N) ->
	io:format("~p stopping, ~p~n", [?MODULE, self()]),
	ok.

handle_call(_Request, _From, _State) ->
	{reply, 0, _State}.

handle_cast(stop, N) ->
	echoserver ! {quit},
	{stop, normal, N};
handle_cast(_Msg, N) ->
	{noreply, N}.

handle_info(_Info, N) ->
	{noreply, N}.

code_change(Old, N, Extra) ->
	{ok, N}.


server_loop(ListenSocket, Count) ->
	% 阻塞，等待连接
	receive
		{quit} ->
			io:format("echoserver will stop~n"),
			gen_tcp:close(ListenSocket);
		{'EXIT', Pid, _Reason } ->
			io:format("Child ~p exit~n", [Pid]),
			server_loop(ListenSocket, Count);
		_ ->
			%io:format("recv ~p~n", Reason)
			true
	after 10 -> 
		 case gen_tcp:accept(ListenSocket, 3000) of
		 	{ok, Socket} ->
				% 创建进程?
				spawn(?MODULE, handle_connect, [Socket, [], Count]),
				server_loop(ListenSocket, Count+1);
			{error, timeout} ->
				server_loop(ListenSocket, Count);
			{error, Reason} ->
				io:format("accept failed~n"),
				gen_tcp:close(ListenSocket)
		end
	end.

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

