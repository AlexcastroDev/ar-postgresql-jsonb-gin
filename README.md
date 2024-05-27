# ActiveRecord Postgress JSON Perfomance measure

# Summary

This summary presents the performance benchmarks for finding entries by UUID under three different scenarios: 

- without an index 
- with an index on a separate column
- with an index on an existing column

The results are shown for two different dataset sizes: 100 entries and 50,000 entries.

| Scenario                | 100 Entries (i/s) | 50,000 Entries (i/s) |
|-------------------------|-------------------|----------------------|
| Without Index           | 1.310k            | 16.300               |
| Index in Separate Column| 5.002k            | 277.447              |
| Index in Existing Column| 2.290k            | 9.525                |


# Current situation (Without index)

### Perform 100 entries

```bash
test-1  | Running Ruby application...
test-1  | ruby 3.3.1 (2024-04-23 revision c56cd86388) [aarch64-linux]
test-1  | Warming up --------------------------------------
test-1  |             find_by_uuid   125.000 i/100ms
test-1  | Calculating -------------------------------------
test-1  |             find_by_uuid      1.310k (±28.4%) i/s -      6.000k in   5.037614s
test-1  | Run options: --seed 9793
```

### Perform 50.000 entries

```bash
test-1  | Running Ruby application...
test-1  | ruby 3.3.1 (2024-04-23 revision c56cd86388) [aarch64-linux]
test-1  | Warming up --------------------------------------
test-1  |             find_by_uuid     1.000 i/100ms
test-1  | Calculating -------------------------------------
test-1  |             find_by_uuid     16.300 (±12.3%) i/s -     81.000 in   5.056892s
```

# Alternative 1: Creating uuids with index in a separate column

### Perform 100 entries

```bash
test-1  | Running Ruby application...
test-1  | ruby 3.3.1 (2024-04-23 revision c56cd86388) [aarch64-linux]
test-1  | Warming up --------------------------------------
test-1  |             find_by_uuid   509.000 i/100ms
test-1  | Calculating -------------------------------------
test-1  |             find_by_uuid      5.002k (± 6.8%) i/s -     24.941k in   5.011577s
```
### Perform 50.000 entries

```bash
test-1  | Running Ruby application...
test-1  | ruby 3.3.1 (2024-04-23 revision c56cd86388) [aarch64-linux]
test-1  | Warming up --------------------------------------
test-1  |             find_by_uuid    24.000 i/100ms
test-1  | Calculating -------------------------------------
test-1  |             find_by_uuid    277.447 (± 5.4%) i/s -      1.392k in   5.034088s
```


# Alternative 2: Adding index in a existent column


### Perform 100 entries

```bash
test-1  | Running Ruby application...
test-1  | ruby 3.3.1 (2024-04-23 revision c56cd86388) [aarch64-linux]
test-1  | Warming up --------------------------------------
test-1  |         find_by_uuid   197.000 i/100ms
test-1  | Calculating -------------------------------------
test-1  |         find_by_uuid      2.290k (± 7.6%) i/s -     11.426k in   5.032567s
```
### Perform 50.000 entries

```bash
test-1  | Running Ruby application...
test-1  | ruby 3.3.1 (2024-04-23 revision c56cd86388) [aarch64-linux]
test-1  | Warming up --------------------------------------
test-1  |         find_by_uuid     1.000 i/100ms
test-1  | Calculating -------------------------------------
test-1  |         find_by_uuid      9.525 (±10.5%) i/s -     47.000 in   5.012350s
```

# How to run

```bash
docker compose up test
```

# References
# https://scalegrid.io/blog/using-jsonb-in-postgresql-how-to-effectively-store-index-json-data-in-postgresql/