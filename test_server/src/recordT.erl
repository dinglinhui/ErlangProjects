%% @author xdinlin
%% @doc @todo Add description to moduleT.


-module(recordT).

%% ====================================================================
%% API functions
%% ====================================================================
-record(x, {name,zz}).
-record(y, {yy,name}).
-export([test1/0, test2/0]).
-define(create(Type,Name), #Type{name = Name}). 


%% ====================================================================
%% Internal functions
%% ====================================================================
test1() -> ?create(x,"Noel"). % -> {x,"Noel",undefined}
test2() -> ?create(y,"Noel"). % -> {y,undefined,"Noel"}


