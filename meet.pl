#!/bin/gprolog --consult-file

:- include('data.pl').
:- include('uniq.pl').

minutes(time(H,M, am), Minutes) :- Minutes is (H mod 12) * 60 + M.

minutes(time(H,M, pm), Minutes) :- Minutes is ((H mod 12 ) * 60 + M) + 720.

lte(T1, T2) :- minutes(T1, Mins1), minutes(T2, Mins2), Mins1 =< Mins2.

later(T1, T2, Later) :- lte(T1, T2), Later = T2.
later(T1, T2, Later) :- lte(T2, T1), Later = T1.

earlier(T1, T2, Earlier) :- lte(T1, T2), Earlier = T1.
earlier(T1, T2, Earlier) :- lte(T2, T1), Earlier = T2.

overlap(slot(S1,E1), slot(S2,E2), slot(Start, End)) :-
    later(S1, S2, Start),
    earlier(E1, E2, End),
    lte(Start, End), 
    Start \== End.



meet(Slot) :-
    people([First|Rest]),
    free(First, FirstSlot), 
    meet_rest(Rest, FirstSlot, Slot).


meet_rest([], Slot, Slot).

meet_rest([Person|Rest], SoFar, Slot) :-
    free(Person, NewSlot),        
    overlap(SoFar, NewSlot, NewSoFar), 
    meet_rest(Rest, NewSoFar, Slot).



people([ann,bob,carla]).

main :- findall(Slot, meet(Slot), Slots),
        uniq(Slots, Uniq),
        write(Uniq), nl, halt.

:- initialization(main).
