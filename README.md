# Qpid Hawk

Bash-based Apache Qpid incremental re/configurator. 

Library uses [`qpid-config`][--help] and [`qpid-stat`][--help] under the hood so they <b>must</b> present in your environment path. Import to your codebase with <code>. "$(dirname "$(readlink -f "$0")")/<b><a href="qpid-hawk">qpid-hawk</a><b>"</code> snippet.

## Contents

1. [Targeting Broker](#targeting-broker)
    1. [`use`](#use)
2. [Creating](#creating)
    2. [`queue`](#queue)
    3. [`binding`](#binding)
        1. [`amq_topic_binding`](#amq_topic_binding)
        2. [`amq_match_binding`](#amq_match_binding)
        2. [`amq_direct_binding`](#amq_direct_binding)
    4. [`exchange`](#exchange)
        1. [`topic_exchange`](#topic_exchange)
        2. [`direct_exchange`](#direct_exchange)
3. [License](#license)

## Targeting Broker

### `use`

Read and cache required Qpid broker info for further usage. Subsequent invokations of other API functions are forwarded to broker selected by latest `use` function.

**Parameter**<br/>
* **`broker_address`** Host and port of broker instance to connect to.

Targeting local broker:
```bash
use '127.0.0.1'
```

## Creating Entities

### `queue`

Create queue if it does not exist. If queue with given name already exist command is omitted.

**Parameters**<br/>
* **`queue_name`** Name of the queue to create.
* Any options of [`qpid-config add queue`][--help] can be specified:
  * **`--durable`** Queue is durable.
  * **`--cluster-durable`** Queue becomes durable if there is only one functioning cluster node.
  * <code><b>--file-count</b> N (8)</code> Number of files in queue's persistence journal.
  * <code><b>--file-size</b>  N (24)</code> File size in pages (64Kib/page).
  * <code><b>--max-queue-size</b> N</code> Maximum in-memory queue size as bytes.
  * <code><b>--max-queue-count</b> N</code>  Maximum in-memory queue size as a number of messages.
  * **`--limit-policy`** Action taken when queue limit is reached:<br/>
    * `none` Default value. Use broker's default policy.
    * `reject` Reject enqueued messages.
    * `flow-to-disk` Page messages to disk.
    * `ring` Replace oldest unacquired message with new.
    * `ring-strict` Replace oldest message, reject if oldest is acquired.
  * **`--order`** Set queue ordering policy:<br/>
    * `fifo` Default value. First in, first out.
    * `lvq` Last Value Queue ordering, allows queue browsing.
    * `lvq-no-browse` Last Value Queue ordering, browsing clients may lose data.
  * <code><b>--generate-queue-events</b> N</code> If set to `1`, every enqueue will generate an event that can be processed by registered listeners (e.g. for replication). If set to `2`, events will be generated for enqueues and dequeues.

Creating two queues parameters reuse:
```bash
default='--durable --cluster-durable'
queue 'test.queue.1' $default
queue 'test.queue.2' $default
```

### `binding`

Create new binding if it does not exist.

**Implemetation Quirk.** Renaming `amq.match` binding key that does not change of any of its parameters requires running script two times sequentially! This issue is planned to be fixed in future releases.

**Parameters**<br/>
* **`exchange_name`** Name of exchange to create.
* **`queue_name`** Name of queue to bind.
* **`binding_key`** Binding key name, empty by default.

Creating `amq.direct` binding to `test.queue.2` queue:
```bash
binding 'amq.direct' 'test.queue.2' 'my_binding'
```

**Shortcuts**<br/>
**`binding`** function can be replaced with several shortcuts to omit explicit exchange **name** specification: **`amq_topic_binding`**, **`amq_match_binding`** and **`amq_direct_binding`** which create bindings for `amq.topic`, `amq.match` and `amq.direct` respectively.

```bash
amq_direct_binding 'test.message.2' 'test.queue.2'
```

### `exchange`

Create new exchange if it does not exist.

**Parameters**<br/>
* **`type`** Type of exchange to use: `topic`, `direct` or other custom type.
* **`exchange_name`** Name of exchange to create.
* Any options of [`qpid-config add exchange`][--help] can be specified:
  * **`--durable`** Exchange is durable.
  * **`--sequence`** Exchange will insert a `qpid.msg_sequence` field in the message header with a value that increments for each message forwarded.
  * **`--ive`** Exchange will behave as an `initial-value-exchange`, keeping a reference to the last message forwarded and enqueuing that message to newly bound queues.

**Shortcuts**<br/>
**`exchange`** function can be replaced with several shortcuts to omit explicit exchange **type** specification: **`topic_exchange`** and **`direct_exchange`** which create `topic` and `direct` exchanges respectively.

## Cleanup

### `cleanup_queues`

Remove queues from Qpid which were not touched during current configuration session.

**Parameter**<br/>
* **`skip_pattern`** Queues matching provided Perl pattern are preserved during cleanup, empty by default.

Excluding system queues from cleanup process:
```bash
cleanup_queues 'topic-|qmfc-|bridge_queue|qmfagent|reply|Temp|Qpid'
```

### `cleanup_bindings`

Remove bindings from Qpid which were not touched during current configuration session.

**Parameter**<br/>
* **`skip_pattern`** Bindings matching provided pattern are preserved during cleanup, empty by default. Each binding is a sting `exchnage_name queue_name binding_key` wich is matched against provided pattern.

Excluding system bindings from cleanup process:
```bash
cleanup_bindings 'qpid.management|qmf.default|qmfagent|reply|bridge|Temp|Qpid'
```

### `cleanup_exchanges`

Remove exchnages from Qpid which were not touched during current configuration session.

**Parameter**<br/>
* **`skip_pattern`** Exchnages matching provided pattern are preserved during cleanup, empty by default.

Excluding system exchanges from cleanup process:
```bash
cleanup_exchanges '^amq\.|^qpid\.|^qmf\.'
```

## License

The code is available under [MIT licence](LICENSE.txt).

[--help]: http://ci.apache.org/projects/qpid/books/0.6/AMQP-Messaging-Broker-CPP-Book/html/ch02.html
