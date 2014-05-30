# Qpid Hawk

Bash-based Apache Qpid incremental re/configurator. 

## Proof

This library provides simple and handy set of functions to work support Qpid setup.

Importing is very easy `. "$(dirname "$(readlink -f "$0")")/qpid-hawk"`

`use(broker_address)` Read and cache required Qpid broker info for further usage. Subsequent invokations of API are forwarded to broker selected by `use` function.
```bash
use '127.0.0.1'
```

### Create

#### Queues
`queue(queue_name, options...)` Create new queue if it does not exist.
```bash
default='--durable --cluster-durable'
queue 'test.queue.1' $default
queue 'test.queue.2' $default
```

#### Bindings
`binding(exchange_name, queue_name, binding_key="", options...)` Create new binding if it does not exist.

`amq_topic_binding(queue_name, binding_key="", options...)` Bind queue to amq.topic with given binding key.

`amq_match_binding(queue_name, binding_key="", options...)` Bind queue to amq.match with given binding key.

Important: to rename `amq.match` binding key without change of any of its parameters it is required to run this script two times sequentially.

`amq_direct_binding(queue_name, binding_key="", options...)` Bind queue to amq.direct with given binding key.

```bash
amq_direct_binding 'test.message.2' 'test.queue.2'
```

#### Exchanges
`exchange(type, name, options...)` Create new exchange.

`topic_exchange(name, options...)` Create new topic exchange.

`direct_exchange(name, options...)` Create new direct exchange.

### Cleanup
`cleanup_queues(skip_pattern=<none>)` Remove queues from Qpid which were not touched during current configuration session.
```bash
# Queues matching provided pattern are preserved during cleanup.
# Excluding system queues from cleanup process.
cleanup_queues '^topic-|^qmfc-|^bridge_queue|^qmfagent|^reply|Temp|Qpid'
```

`cleanup_bindings(skip_pattern=<none>)` Remove bindings from Qpid which were not touched during current configuration session.
```bash
# Bindings matching provided pattern are preserved during cleanup.
# Each binding is a sting 'exchnage_name queue_name binding_key'.
cleanup_bindings '^qpid.management|^qmf.default|qmfagent|reply|bridge|Temp|Qpid'
```

`cleanup_exchanges(skip_pattern=<none>)` Remove exchnages from Qpid which were not touched during current configuration session.
```bash
# Exchnages matching provided pattern are preserved during cleanup.
# Excluding system exchanges from cleanup process.
cleanup_exchanges '^amq\.|^qpid\.|^qmf\.'
```

## License

The code is available under [MIT licence](LICENSE.txt).
