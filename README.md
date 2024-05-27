# ActiveRecord Postgress JSON Perfomance measure

# Summary

This summary presents the performance benchmarks for finding entries by UUID under three different scenarios: 

- without an index 
- with an index on a separate column
- with an index on an existing column

The results are shown for two different dataset sizes: 100 entries and 50,000 entries.

| Scenario                                | 100 Entries (i/s) | 50,000 Entries (i/s) |
|-----------------------------------------|-------------------|----------------------|
| Without Index                           | 1.310k            | 16.300               |
| Index in Separate Column                | 5.002k            | 277.447              |
| Index in Existing Column                | 2.290k            | 9.525                |
| Index in Existing Column second try     | 4.105k            | 95.707               |

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

improve it a little bit more, after start creating manual testing i got this:

```sql
CREATE INDEX idx_users_on_thirdparty_infos_identities_uuid ON users USING gin (thirdparty_infos);
```

And to be sure that this will work

```sql
EXPLAIN ANALYZE
SELECT *
FROM users
WHERE thirdparty_infos @> '{"identities": [{"uuid": "656ff884-99e8-4624-95d4-50d3952d2c38"}]}';
```

and the result is:

| Step | Operation                                      | Details                                                                                          | Cost Range       | Actual Time (ms) | Rows | Loops |
|------|------------------------------------------------|--------------------------------------------------------------------------------------------------|------------------|------------------|------|-------|
| 1    | Bitmap Heap Scan on users                      | Cost: 40.04..59.13, Rows: 5, Width: 160                                                          | 40.04..59.13     | 0.345..0.346     | 0    | 1     |
|      | Recheck Condition                              | `(thirdparty_infos @> '{"identities": [{"uuid": "656ff884-99e8-4624-95d4-50d3952d2c38"}]}'::jsonb)` |                  |                  |      |       |
| 2    | Bitmap Index Scan on index_users_on_thirdparty_infos | Cost: 0.00..40.04, Rows: 5, Width: 0                                                               | 0.00..40.04      | 0.337..0.338     | 0    | 1     |
|      | Index Condition                                | `(thirdparty_infos @> '{"identities": [{"uuid": "656ff884-99e8-4624-95d4-50d3952d2c38"}]}'::jsonb)` |                  |                  |      |       |
|      |                                                |                                                                                                  |                  |                  |      |       |
|      | **Planning Time**                              |                                                                                                  |                  | 0.688            |      |       |
|      | **Execution Time**                             |                                                                                                  |                  | 0.495            |      |       |


### Perform 100 entries

```bash
test-1  | Running Ruby application...
test-1  | ruby 3.3.1 (2024-04-23 revision c56cd86388) [aarch64-linux]
test-1  | Warming up --------------------------------------
test-1  |         find_by_uuid   408.000 i/100ms
test-1  | Calculating -------------------------------------
test-1  |         find_by_uuid      4.105k (±11.0%) i/s -     20.400k in   5.051942s
```

### Perform 50.000 entries

```bash
test-1  | Running Ruby application...
test-1  | ruby 3.3.1 (2024-04-23 revision c56cd86388) [aarch64-linux]
test-1  | Warming up --------------------------------------
test-1  |         find_by_uuid     9.000 i/100ms
test-1  | Calculating -------------------------------------
test-1  |         find_by_uuid     95.707 (±10.4%) i/s -    477.000 in   5.058234s
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