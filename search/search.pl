%%%%%%%%%%%%%%%%%%%%%%
% search/search.pl
%%%%%%%%%%%%%%%%%%%%%%

% Entry point: start at the initial room (picking up any key there),
% do a BFS on states state(Room,Keys,RevPath), then reverse the RevPath.
search(Actions) :-
    initial(Start),
    update_keys(Start, [], Keys0),          % pick up key at Start (no action)
    bfs([state(Start,Keys0,[])],             % initial queue
        [room_keys(Start,Keys0)],            % visited set
        RevActions),
    reverse(RevActions, Actions).

% Succeed when the front of the queue is at the treasure.
bfs([state(Room,_,PathRev)|_], _, PathRev) :-
    treasure(Room), !.

% Otherwise expand the front state:
bfs([state(Room,Keys,PathRev)|Rest], Visited, ActionsRev) :-
    findall(
       state(Next, NextKeys, ActsRev),
       edge_state(Room, Keys, PathRev, Next, NextKeys, ActsRev),
       NewStates
    ),
    add_states(NewStates, Visited, Visited2),
    append(Rest, NewStates, Queue2),
    bfs(Queue2, Visited2, ActionsRev).

% Build one successor state via either an unlocked or locked door.
edge_state(Room, Keys, PathRev, Next, NextKeys, NewPathRev) :-
    % 1) Unlocked door move
    ( door(Room, Next)
    ; door(Next, Room)
    ),
    update_keys(Next, Keys, NextKeys),
    % record only a move/2
    NewPathRev = [move(Room,Next)|PathRev].

edge_state(Room, Keys, PathRev, Next, NextKeys, NewPathRev) :-
    % 2) Locked door: must have the key, and record unlock(Color)+move
    ( locked_door(Room, Next, Color)
    ; locked_door(Next, Room, Color)
    ),
    member(Color, Keys),
    update_keys(Next, Keys, NextKeys),
    NewPathRev = [move(Room,Next), unlock(Color) | PathRev].


% Add each new (Room,Keys) combination into the visited set.
add_states([], Visited, Visited).
add_states([state(R,K,_)|T], Visited, [room_keys(R,K)|V2]) :-
    add_states(T, Visited, V2).


% If there's a key in the room you don't yet have, pick it up
% (no action is recorded for pickup).
update_keys(Room, OldKeys, NewKeys) :-
    key(Room, Color),
    \+ member(Color, OldKeys),
    sort([Color|OldKeys], NewKeys), !.
update_keys(_, Keys, Keys).
