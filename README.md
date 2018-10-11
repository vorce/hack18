# hack18

```elixir
{:ok, client} = Hack18.Net.Client.connect("tcp://localhost:3418")
remote_node_id = Hack18.Identity.new("remote")
remote_player = %Hack18.Player.Model{Hack18.Player.Model.new() | start_node: remote_node_id}
remote_state = %Hack18.GameState{players: Loom.AWORSet.new() |> Loom.AWORSet.add(remote_node_id.uuid, remote_player), node_id: remote_node_id}
Hack18.Net.Client.send_state(client, remote_state)
```

## Run it

`make run` (or simply `mix scenic.run`)

### Controls

