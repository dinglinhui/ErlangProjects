-module(train1).
-compile(export_all).

f(1) -> 1;
f(N) -> 10*f(N-1).

func(N) -> f(N) - 1. 
