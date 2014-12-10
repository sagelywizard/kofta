-module(kofta_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type, A), {I, {I, start_link, A}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    ets:new(broker_id_pids, [named_table, public]),
    ets:new(broker_host_pids, [named_table, public]),
    {ok, {{one_for_one, 5, 10}, [
        ?CHILD(ets_lru, worker, [kofta_leader_lru, [{max_size, 1024*1024}]]),
        ?CHILD(kofta_cluster_sup, supervisor, []),
        ?CHILD(kofta_metadata, worker, [])
    ]}}.
