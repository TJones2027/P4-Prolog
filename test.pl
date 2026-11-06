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

meetone(Person, slot(QStart, QEnd)) :-
    free(Person, slot(FStart, FEnd)),
    lte(FStart, QStart),
    lte(QEnd, FEnd).

people([ann,bob,carla]).

% This program shows how to "unit test" a predicate, named foo.
% The first foo fact prevents an "existence_error".
% The second foo fact models the predicate under test,
% which might evaluate to true or false, 

%lte tests
test_lte(Time1, Time2, TestName) :-
	(lte(Time1, Time2) ->
		write(TestName), write(' passed'), nl
	;
		write(TestName), write(' failed'), nl
	).

test_not_lte(Time1, Time2, TestName) :-
	(lte(Time1, Time2) ->
		write(TestName), write(' failed'), nl
	;
		write(TestName), write(' passed'), nl
	).


%later test function
test_later(T1, T2, Expected, TestName) :-
	(later(T1, T2, Result), Result == Expected ->
		write(TestName), write(' passed'), nl
	;
		write(TestName), write(' failed'), nl
	).
%earlier test function
	test_earlier(T1, T2, Expected, TestName) :-
	(earlier(T1, T2, Result), Result == Expected ->
		write(TestName), write(' passed'), nl
	;
		write(TestName), write(' failed'), nl
	).
/*
Meant to test the overlap function and test for edge cases and errors
*/

% overlap test
test_overlap(SlotA, SlotB, Expected, TestName) :-
	( overlap(SlotA, SlotB, Result), Result == Expected ->
		write(TestName), write(' passed'), nl
	;
		write(TestName), write(' failed'), nl
	).

% no overlap test
test_no_overlap(SlotA, SlotB, TestName) :-
	( overlap(SlotA, SlotB, _) -> 
		write(TestName), write(' failed'), nl
	;
		write(TestName), write(' passed'), nl
	).

test_meetone(Slot, Expected, TestName) :-
	findall(Person, meetone(Person, Slot), People),
	( People == Expected ->
		write(TestName), write(' passed'), nl
	;
		write(TestName), write(' failed'), nl
	).

test_meet(People, Expected, TestName) :-
	People = [First|Rest],
	findall(Slot,
	        ( free(First, FirstSlot), meet_rest(Rest, FirstSlot, Slot) ),
	        Raw),
	uniq(Raw, Slots),
	( Slots == Expected ->
		write(TestName), write(' passed'), nl
	;
		write(TestName), write(' failed'), nl
	).



		
/*
Tests
*/

main :-
		test_lte(time(8,30,am), time(8,31,am), 'lte basic'),
        test_lte(time(8,0,am), time(8,0,am), 'lte equal'),
        test_lte(time(12,0,pm), time(1,0,pm), 'lte noon'),
        test_lte(time(12,0,am), time(8,0,am), 'lte midnight'),
        test_lte(time(11,30,am), time(1,0,pm), 'lte across noon'),
        test_not_lte(time(8,0,pm), time(8,0,am), 'lte pm vs am'),
        test_not_lte(time(8,31,am), time(8,30,am), 'lte reversed'),
		%earlier and later tests
		test_later(time(8,0,am), time(9,0,am), time(9,0,am), 'later basic'),
		test_later(time(9,0,am), time(8,0,am), time(9,0,am), 'later reversed'),
		test_later(time(8,0,am), time(1,0,pm), time(1,0,pm), 'later across noon'),
		test_earlier(time(9,0,am), time(10,0,am), time(9,0,am), 'earlier'),
		test_earlier(time(10,0,am), time(9,0,am), time(9,0,am), 'earlier reversed'),
		test_earlier(time(11,0,am), time(1,0,pm), time(11,0,am), 'earlier across noon'),
		% Calling overlap for tests
		test_overlap(slot(time(8,0,am),time(9,0,am)), slot(time(7,0,am),time(8,30,am)),
        slot(time(8,0,am),time(8,30,am)), 'overlap ann/bob'),
		test_overlap(slot(time(7,0,am),time(8,30,am)), slot(time(8,0,am),time(9,0,am)),
        slot(time(8,0,am),time(8,30,am)), 'overlap bob/ann swapped'),
		test_overlap(slot(time(10,0,am),time(11,0,am)), slot(time(10,0,am),time(10,15,am)),
        slot(time(10,0,am),time(10,15,am)), 'overlap ann/carla'),
		test_overlap(slot(time(11,30,am),time(9,0,pm)), slot(time(11,0,am),time(8,30,pm)),
        slot(time(11,30,am),time(8,30,pm)), 'overlap bob/carla'),
		test_overlap(slot(time(8,0,am),time(9,0,am)), slot(time(8,15,am),time(8,45,am)),
        slot(time(8,15,am),time(8,45,am)), 'overlap contains'),
		test_overlap(slot(time(8,15,am),time(8,45,am)), slot(time(8,0,am),time(9,0,am)),
        slot(time(8,15,am),time(8,45,am)), 'overlap contained'),
		test_no_overlap(slot(time(8,0,am),time(9,0,am)), slot(time(9,0,am),time(10,0,am)),
        'overlap touching'),
		test_no_overlap(slot(time(9,0,am),time(10,0,am)), slot(time(8,0,am),time(9,0,am)),
        'overlap touching swapped'),
		test_no_overlap(slot(time(8,0,am),time(9,0,am)), slot(time(10,0,am),time(11,0,am)),
        'overlap disjoint'),

		% tests meetone
		test_meetone(slot(time(8,30,am),time(8,45,am)), [ann,carla,dave], 'meetone 8:30'),
		test_meetone(slot(time(5,30,am),time(6,45,am)), [], 'meetone none'),
		test_meetone(slot(time(8,45,am), time(9,15,am)), [], 'meetone multiple ends'),

		% tests meet
		test_meet([ann,bob,carla],
        [slot(time(8,0,am),time(8,30,am)),
        slot(time(10,0,am),time(10,15,am)),
        slot(time(8,0,pm),time(8,30,pm))],
        'meet ann/bob/carla'),
		test_meet([ann,ed], [], 'meet ann/ed'),

			
        halt.

:- initialization(main).
