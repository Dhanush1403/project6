% Entry point: start from the initial room, collect any key there,
% then run BFS and reverse the resulting move list.
search(Actions) :-
    initial(Start),
    update_keys(Start, [], Keys0),
    bfs([state(Start, Keys0, [])], [room_keys(Start, Keys0)], RevActions),
    reverse(RevActions, Actions).

% bfs(+Queue, +Visited, -ActionsRev)
%   Queue holds states state(Room,Keys,PathRev). We succeed when
%   the front state is at the treasure; otherwise expand neighbors.
bfs([state(Room, _, PathRev)|_], _, PathRev) :-
    treasure(Room), !.
bfs([state(Room, Keys, PathRev)|Rest], Visited, ActionsRev) :-
    findall(
      state(Next, NextKeys, [move(Room,Next)|PathRev]),
      ( neighbor(Room, Keys, Next),
        update_keys(Next, Keys, NextKeys),
        \+ member(room_keys(Next, NextKeys), Visited)
      ),
      NewStates
    ),
    add_states(NewStates, Visited, Visited2),
    append(Rest, NewStates, Queue2),
    bfs(Queue2, Visited2, ActionsRev).

% add_states(+States, +Visited, -VisitedOut)
%   Add each state’s (Room,Keys) pair into the visited list.
add_states([], Visited, Visited).
add_states([state(R,K,_)|T], Visited, [room_keys(R,K)|V2]) :-
    add_states(T, Visited, V2).

% neighbor(+Room, +Keys, -Next)
%   You can move through any undirected door; for locked doors,
%   you must already carry the matching key.
neighbor(Room, _, Next) :-
    door(Room, Next).
neighbor(Room, _, Next) :-
    door(Next, Room).
neighbor(Room, Keys, Next) :-
    locked_door(Room, Next, Color),
    member(Color, Keys).
neighbor(Room, Keys, Next) :-
    locked_door(Next, Room, Color),
    member(Color, Keys).

% update_keys(+Room, +OldKeys, -NewKeys)
%   If Room contains a key you don’t already have, pick it up.
update_keys(Room, OldKeys, NewKeys) :-
    key(Room, Color),
    \+ member(Color, OldKeys),
    sort([Color|OldKeys], NewKeys), !.
update_keys(_, Keys, Keys).

