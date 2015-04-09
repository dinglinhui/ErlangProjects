%% @author Kevin
%% @doc @todo Add description to xdinlin.


-module(xdinlin).

%% ====================================================================
%% API functions
%% ====================================================================
-export([myTst/0]).



%% ====================================================================
%% Internal functions
%% ====================================================================
myTst() ->
%% 	reverse([1,2,3,4,5,6]).
%% 	getLength([1,2,3,[[[[4],[]],[[[[5]]],[6,[7,[8]],9]],10]],[11],[[12],13]]).
%% 	classDiffer([1,2,3,a,b,"d","c"]).
%% 	getNumber([{high, 4},{width,6},{weight,16}], width).
%% 	str_to_ipv4("123.234.255.010").
%% 	str_to_ipv4("150.236.11.1").
%% 	split("Ah, I have a    dream! ").
	is_leap_year(2000).
	
%% reverse
%% 4. [1,2,3,...,5] ->[5,...,3,2,1]   (not use lists:reverse)
reverse(L) -> 
	reverse(L, []).
	
reverse([H|T], Rev) ->
	reverse(T, [H|Rev]);

reverse([], Rev) ->
	Rev.

%% getLength
%% 1. implement function  my_len/1, to get the number of elements in a list which include more sub-list.
%% All to the elements are integer.
%% for example:
%% my_len(A)                A
%% 0                                                []
%% 3                                               [1,2,3]
%% 8                                               [1,2,[3],[],[4,5,6,[7,8],[]]]
%% 7                                               [1,2,3,[[[[4]],[[[[5]]],6]]],7]
%% 13                                      [1,2,3,[[[[4],[]],[[[[5]]],[6,[7,[8]],9]],10]],[11],[[12],13]]


%% getLength([H|T], Num) ->
%% 	io:format("Head ~p Tail ~p Num ~p ~n", [H, T, Num]),
%% 	case is_list(H) orelse is_tuple(H) of
%% 		true -> getLength(T, getLength(H, Num));
%% 		false -> getLength(T, Num+1)
%% 	end;
getLength(L) -> 
	 getLength(L, 0).

getLength([H|T], Num) when is_list(H) orelse is_tuple(H) ->
	getLength(T, getLength(H, Num));

getLength([H|T], Num) ->
	getLength(T, Num+1);

getLength([], Num) ->
	Num.

%% sort
%% 5. [1,a,"s","d",3,b]->[[1,3],[a,b],["s","d"]]
classDiffer(L) ->
	classDiffer(L, [], [], []).
	
classDiffer([H|T], Int, Atom, Oth) when is_integer(H) ->
    classDiffer(T, [H|Int], Atom, Oth);
    
classDiffer([H|T], Int, Atom, Oth) when is_atom(H) ->
    classDiffer(T, Int, [H|Atom], Oth);
    
classDiffer([H|T], Int, Atom, Oth) ->
	classDiffer(T, Int, Atom, [H|Oth]);

classDiffer([], Int, Atom, Oth) ->
	[[reverse(Int)],[reverse(Atom)],[reverse(Oth)]].


%% 6. L=[{Name,Value},...]
%%    e.g.
%%    L=[{high, 4},{width,6},{weight,16}]
%%  
%%    4=fun(L,high)
%%    6=fun(L,width) 
%%    undefined=fun(L,high1)
%%  
%%    What is fun/2?   (not use lists:xxxx )
getNumber([{Var, N}|T], Var) -> 
    N;
    
getNumber([{What, N}|T], Var) -> 
	case What =:= Var of
		true -> N;
		false -> getNumber(T, Var)
	end;

getNumber([], Var) -> 
	undefined.

%% 7. decode IPv4 adddress
%%    str_to_ipv4("150.236.11.1")->{150,236,11,1}
%%    str_to_ipv4("150.236.1234.1")->{error, bad_format}

str_to_ipv4(X) ->
	str_to_ipv4(X, [], "").

str_to_ipv4([H|T], Ip, Item) ->
%% 	io:format("Head ~w Tail ~w Ip ~w Item ~w ~n", [H, T, Ip, Item]),
	if 
		H =:= $. -> 
            IpItem = list_to_integer(reverse(Item)),
%% 					io:format("IpItem ~p Ip ~p ~n", [IpItem, Ip]),
					case IpItem > 255 orelse IpItem < 0 of 
						true ->
                            {error, bad_format};
						false -> 
                            str_to_ipv4(T, [IpItem|Ip], "")
					end;
		H >= $0 andalso H =< $9 -> 
            str_to_ipv4(T, Ip, [H|Item]);
		true -> {error, bad_format}
	end;

str_to_ipv4([], Ip, Item) ->
%% 	io:format("Ip ~p Item ~p ~n", [Ip, Item]),
	reverse([list_to_integer(reverse(Item))|Ip]).

%% 8. split words.
%%    split("Ah, I have a    dream!") ->["Ah","I","have","a","dream"].
split(L) ->
 	split(L, [], "").

split([H|T], WordList, Word) ->
%% 	io:format("Head ~w Tail ~w WordList ~w Word ~w ~n", [H, T, WordList, Word]),
	if 
        (H >= $a andalso H =< $z) orelse (H >= $A andalso H =< $Z) -> 
			split(T, WordList, [H|Word]);
		true -> 
			case Word =:= [] of
				true -> split(T, WordList, "");
				false -> split(T, [reverse(Word)|WordList], "")
			end
	end;

%% split([], WordList, Word) -> 
%% 	case Word =:= "" of
%% 		true -> reverse(WordList);
%% 		false -> reverse([reverse(Word)|WordList])
%% 	end.

split([], WordList, "") -> 
	reverse(WordList);

split([], WordList, Word) -> 
	reverse([reverse(Word)|WordList]).

%% 9. check the year is leap-year or not.
%%    Please google the leap-year rule.
%%  
%%    is_leap_year(Int): true|false
%% 	  If n Mod 400 = 0 Or (n Mod 4 = 0 And n Mod 100 <> 0) Then it's leap_year

%% is_leap_year(Int) ->
%% 	case is_integer(Int) andalso Int >= 0 of
%% 		true ->
%% 			case (Int rem 4 =:= 0 andalso Int rem 100 /= 0 ) orelse (Int rem 400 =:= 0) of 
%% 				true -> true;
%% 				false -> false
%% 			end;
%% 		false -> false
%% 	end.

is_leap_year(Int) when is_integer(Int) andalso Int >= 0 ->
	case (Int rem 4 =:= 0 andalso Int rem 100 /= 0 ) orelse (Int rem 400 =:= 0) of 
		true -> true;
		false -> false
	end.



