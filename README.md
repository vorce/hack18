# hack18

Some sort of starting point for a p2p game with offline support.

## Technobabble

The game state is represented as a CRDT set. Which is
sent to all nodes.

Connectivity works with built in erlang node clustering.

## Run it

Running `./launch.sh` will launch several game instances locally.

### Controls

- Left mouse click: select player.
- W,A,S,D keys: navigate.
- Mouse pointer: aim
- **TODO** Space: shoot 

