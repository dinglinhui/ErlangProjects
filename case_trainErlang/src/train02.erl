%% @author xdinlin
%% @doc @todo Add description to train02.


-module(train02).

%% ====================================================================
%% Internal functions
%% ====================================================================
-export([remove_angle_bracket/1, remove_outside_angle_bracket/1]).



%% ====================================================================
%% Internal functions
%% ====================================================================
remove_angle_bracket(L) ->
	remove_angle_bracket2(L, []). 

remove_angle_bracket2([H|T], Angle_bracket_context) -> 
	case H =:= $< of 
		true -> remove_angle_bracket3(T, []);
		false -> remove_angle_bracket2(T, [H|Angle_bracket_context])
	end;

remove_angle_bracket2([], Angle_bracket_context) ->
	{lists:reverse(Angle_bracket_context)}.

remove_angle_bracket3([H|T], Angle_bracket_context) ->
	case H =:= $> of 
		true -> remove_angle_bracket3([], lists:reverse(lists:reverse(Angle_bracket_context)++T));
		false -> remove_angle_bracket3(T, [H|Angle_bracket_context])
	end;

remove_angle_bracket3([], Angle_bracket_context) ->
	{lists:reverse(Angle_bracket_context)}.

%% ====================================================================
%% remove_outside_angle_bracket
%% ====================================================================
remove_outside_angle_bracket([H|T] = _L) -> 
	case H =:= $< of
		true -> remove_outside_angle_bracket2([], lists:reverse(T));
		false -> {[]}
	end.

remove_outside_angle_bracket2([], [H|T]) -> 
	case H =:= $> of
		true -> {lists:reverse(T)};
		false -> {[]}
	end. 