-module(master).
-behavior(supervisor).

-export([start/0, stop/0, start_monitor/0]).
-export([init/1]).

%% 从shell运行的时候调用此函数
start() ->
	%% 创建master进程
	register(master, spawn(?MODULE, start_monitor, [])).

stop() ->
	master ! {quit}.	

start_monitor() ->
	io:format("master started: ~p~n", [self()]),
	%% 创建监控子进程，注册为monitor，并运行 init/1
	{ok, Pid} = supervisor:start_link({local, monitor}, ?MODULE, []),
	%unlink(Pid),
	wait().

%% monitor进程运行init/1，启动所有被监控的子进程，并监控这些进程
init(FileName) ->
	io:format("enter init, ~s, ~p~n", [FileName, self()]),
	%% 运行 es2:start_link
	ChildSpec = {es, {es2, start_link, []}, permanent, 2000, worker, [es2]},
	%% 监控规范：被监控进程退出后，重启之，重启次数100，重启间隔10ms
	{ok, {{one_for_one, 100, 10}, [ChildSpec]}}.

%% master进程循环等待退出消息
wait() ->
	receive
		{quit} ->
			io:format("recv quit msg~n");
			%%master进程退出，从而导致monitor及所有monitor的子进程都退出
		{'EXIT', Pid, Reason} ->
			io:format("Child ~p exit~n", [Pid]),
			wait()
	end.

