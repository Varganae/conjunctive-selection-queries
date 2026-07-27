# Conjunctive Selection Queries on Database ADT

Implementation and optimization of **conjunctive selection queries** within a custom Database Abstract Data Type (ADT). This includes both in-memory and disk-based query evaluation routines designed to minimize block transfers through B+-tree index optimization.

---

## 1. Introduction

This project implements conjunctive selection queries within the existing Database ADT:
* `select-from/eq-and`: Handles result sets small enough to fit within main memory.
* `select-from/eq-and+`: Handles large result sets that exceed memory capacity by streaming results directly to external storage.

The primary goal of these conjunctive queries is to maximize efficiency by minimizing the number of disk block transfers. The implementation intelligently evaluates available B+-tree indices across the attributes specified in the query predicates.

---

## 2. Implementation & Design Choices

### 2.1 Implementation Strategy
Modifications are isolated in:
* `database.rkt`: Core search and evaluation logic.
* `schema.rkt`: Schema abstraction layer updates.

To execute conjunctive queries efficiently, index-based access paths are preferred over sequential table scans:

1. **Index Selection:** The algorithm inspects all conjunctive conditions (`AND` clauses). If a B-tree index exists for at least one attribute, it is chosen as the primary access path. If multiple indexed attributes are present, the algorithm selects the first matching index found.
2. **Record Fetching:** The system uses the chosen B-tree index (`btree:find!` followed by `btree:set-current-to-next!`) to retrieve Record Identifiers (RCIDs) matching the indexed predicate.
3. **Direct Table Access:** Using the retrieved RCIDs, the system jumps directly to the record's location in the table (`table:current!`) to fetch the full tuple.
4. **In-Memory Filtering:** Since the index covers only one predicate, remaining non-indexed conditions are filtered in memory using the `matches-conds?` predicate.

---

### 2.2 Performance & Complexity

Disk block transfers represent the primary performance bottleneck in external storage systems.

* **Sequential Scan:** Requires reading all table blocks, leading to an $\mathcal{O}(N)$ block transfer complexity.
* **Index-Based Search:** Reduces block reads to the height of the B-tree, achieving an $\mathcal{O}(\log N)$ lookup complexity.

Data processing is handled iteratively using active pointers from the B-tree and Table ADTs, avoiding intermediate list allocations in memory. This maintains an $\mathcal{O}(1)$ auxiliary space complexity per record processed, keeping queries execution-ready even when datasets exceed available RAM.

---

### 2.3 Schema ADT Extension

The function `scma:description` was added to the Schema ADT to expose table metadata (e.g., column names and field types). 

* **Purpose:** The disk-backed `+` query variant requires this metadata to instantiate output tables on disk.
* **Encapsulation:** By providing `scma:description`, the Database module does not need to parse the underlying binary layout of the schema block directly, preserving ADT encapsulation.

---

### 2.4 Disk-Backed Query Execution (`select-from/eq-and+`)

The `select-from/eq-and+` function prevents memory overflow when a query yields a large result set:

* **Direct Disk Streaming:** Instead of collecting all matching records into an in-memory list, each matching record is written directly to a new output table on disk via `tbl:insert!`.
* **Scalability:** Ensures system stability and continuous operation even when result set sizes exceed physical memory limits.
* **Persistence:** The generated output table remains persisted on disk for subsequent queries.
