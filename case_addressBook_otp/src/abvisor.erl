%% @author xdinlin
%% @doc @todo Add description to abvisor.


-module(abvisor).
-behaviour(supervisor).
-export([init/1]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0]).

start() -> 
	io:format("supervisor started: ~p~n", [self()]),
	{ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
	unlink(Pid).
		
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



