# pg_paxos-evaluation

## About

[pg_paxos](https://github.com/citusdata/pg_paxos) is a PostgreSQL-based implementation of the well known [Paxos](https://en.wikipedia.org/wiki/Paxos_%28computer_science%29) consensus algorithm.

This repository contains the source code to run the technology evaluation that [8Kdata](https://8kdata.com) has performed of pg_paxos. This work is sponsored by [Citus Data](https://www.citusdata.com/).

This evaluation consists on simulating a distribitued job execution queue on top of pg_paxos. By its nature, this queue is conflict-free. The results are published on Citus Data's [blog](https://www.citusdata.com/blog).

