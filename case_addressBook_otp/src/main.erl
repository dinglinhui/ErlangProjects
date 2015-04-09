%% @author xdinlin
%% @doc @todo Add description to addressBook_supervisor.


-module(main).
-behaviour(supervisor).
-export([init/1]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0, stop/0, start_monitor/0]).

start() -> 
	register(main, spawn(?MODULE, start_monitor, [])).

stop() ->
	main ! {quit}.	

start_monitor() ->
	io:format("supervisor started: ~p~n", [self()]),
	%% 创建监控子进程，注册为monitor，并运行 init/1
	{ok, Pid} = supervisor:start_link({local, monitor}, ?MODULE, []),
	unlink(Pid),
	wait().

%% init/1
init([]) ->
	io:format("enter init ~p~n", [self()]),
%% 	gen_event:swap_handler(alarm_handler, 
%% 						 {alarm_handler, swap},
%% 						 {ab_alarm_handler, xyz}),
	
	%% 运行 es2:start_link
	%% 监控规范：被监控进程退出后，重启之，重启次数100，重启间隔10ms
    {ok, {{one_for_one, 100, 10}, 
		  [{abserver,
				{abserver, start, []},
	      		permanent,
				2000,
			  	worker,
			  	[abserver]}]
		 }}.

%% master进程循环等待退出消息
wait() ->
	receive
		{quit} ->
			io:format("recv quit msg~n");
			%%main进程退出，从而导致monitor及所有monitor的子进程都退出
		{'EXIT', Pid, Reason} ->
			io:format("Child ~p ~p exit~n", [Pid, Reason]),
			wait()
	end.


