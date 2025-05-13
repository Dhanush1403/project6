% parse/1 succeeds exactly when the entire token list X
% is a (Lines) according to the grammar.
parse(X) :-
    lines(X, []).

% Lines → Line
%       | Line ; Lines
lines(Input, Rest) :-
    line(Input, Rest).
lines(Input, Rest) :-
    line(Input, Mid),
    Mid = [';'|AfterSemi],
    lines(AfterSemi, Rest).

% Line → Num
%       | Num , Line
line(Input, Rest) :-
    num(Input, Rest).
line(Input, Rest) :-
    num(Input, Mid),
    Mid = [','|AfterComma],
    line(AfterComma, Rest).

% Num → Digit
%      | Digit Num
num(Input, Rest) :-
    digit(Input, Rest).
num(Input, Rest) :-
    digit(Input, Mid),
    num(Mid, Rest).

% Digit → '0' | '1' | ... | '9'
digit(['0'|Rest], Rest).
digit(['1'|Rest], Rest).
digit(['2'|Rest], Rest).
digit(['3'|Rest], Rest).
digit(['4'|Rest], Rest).
digit(['5'|Rest], Rest).
digit(['6'|Rest], Rest).
digit(['7'|Rest], Rest).
digit(['8'|Rest], Rest).
digit(['9'|Rest], Rest).
