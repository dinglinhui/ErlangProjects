%% @author xdinlin
%% @doc @todo Add description to motor_controller.


-module(motor_controller).

%% ====================================================================
%% API functions
%% ====================================================================
-export([add_event_handler/0]).



%% ====================================================================
%% Internal functions
%% ====================================================================
add_event_handler() ->
	event_handler:add_handler(errors, fun controller/1).

controller(too_hot) ->
	io:format("Turn off the motor~n");
controller(X) ->
	io:format("~w ignored event: ~p~n", [?MODULE, X]).

