#!/bin/gprolog --consult-file

:- include('data.pl').



minutes(time(H,M, am), Minutes) :- Minutes is (H mod 12) * 60 + M.

minutes(time(H,M, pm), Minutes) :- Minutes is ((H mod 12 ) * 60 + M) + 720.

lte(T1, T2) :- minutes(T1, Mins1), minutes(T2, Mins2), Mins1 =< Mins2.


meetone(Person, slot(QStart, QEnd)) :-
    free(Person, slot(FStart, FEnd)),
    lte(FStart, QStart),
    lte(QEnd, FEnd).



main :- findall(Person,
		meetone(Person,slot(time(8,30,am),time(8,45,am))),
		People),
	write(People), nl, halt.


:- initialization(main).
