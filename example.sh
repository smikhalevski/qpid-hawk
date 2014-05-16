#!/bin/bash

# Important: to rename amq.match binding key without change of any of its
# parameters it is required to run this script two times sequentially.

. "$(dirname "$(readlink -f "$0")")/qpid-hawk"

use '127.0.0.1'

echo 
echo Queues
echo ------
default='--durable --cluster-durable'
queue 'test.queue.1' $default
queue 'test.queue.2' $default

echo 
echo Bindings
echo --------
amq_direct_binding 'test.message.2' 'test.queue.2'

echo
echo Cleanup Queues
echo --------------
# Queues matching provided pattern are preserved during cleanup.
# Excluding system queues from cleanup process.
cleanup_queues '^topic-|^qmfc-|^bridge_queue|^qmfagent|^reply|Temp|Qpid'

echo
echo Cleanup Bindings
echo ----------------
# Bindings matching provided pattern are preserved during cleanup.
# Each binding is a sting 'exchnage_name queue_name binding_key'.
cleanup_bindings '^qpid.management|^qmf.default|qmfagent|reply|bridge|Temp|Qpid'

echo
echo Cleanup Exchanges
echo -----------------
# Exchnages matching provided pattern are preserved during cleanup.
# Excluding system exchanges from cleanup process.
cleanup_exchanges '^amq\.|^qpid\.|^qmf\.'
