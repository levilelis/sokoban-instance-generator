# Sokoban Instance Generator

Code for **β**, a system that generates hard, **solvable** initial states for Sokoban
puzzles. It accompanies the paper:

> Dâmaris S. Bento, André G. Pereira, and Levi H. S. Lelis.
> **Procedural Generation of Initial States of Sokoban.**
> *International Joint Conference on Artificial Intelligence (IJCAI)*, 2019.
> [[paper (PDF)]](https://levilelis.github.io/papers/2019/bentoPL19.pdf) ·
> [[IJCAI proceedings]](https://doi.org/10.24963/ijcai.2019/646)

Given a maze and its goal locations, β searches for a placement of the boxes and the
player that is hard to solve. On the 90 mazes of the xSokoban benchmark, β generates
initial states that are harder for a specialized Sokoban solver than the initial states
created by human experts.

> **Supported variants.** This repository supports the variants of β that use pattern
> databases over 1, 3, or 4 boxes (PDB1, PDB3, PDB4), including the best-performing
> variant from the paper. Variants that use PDB2 depend on the third-party
> [Blossom V](https://pub.ist.ac.at/~vnk/software.html) library, which we cannot
> redistribute. They are available as an [optional build](#optional-pdb2-variants-blossom-v).

## How it works

β runs a **backward greedy best-first search** that starts from the goal state (every box
on a goal) and applies "pull" moves, the inverses of Sokoban's push moves. Every
state reached this way has a solution by construction, so β never has to check
solvability, which is PSPACE-complete in Sokoban. When the time or memory limit is
reached, β returns the state with the largest objective value it has seen.

States are expanded and ranked by a lexicographic **ordering** of three metrics:

| Metric | Notation | Meaning |
|---|---|---|
| Solution length | `h^PDBk` | Additive pattern-database (PDB) heuristic over patterns of *k* boxes (plus the player). It approximates the optimal number of pushes. |
| Conflicts of order *k* | `kC = h^PDBk − h^PDB(k−1)` | The extra pushes caused by interactions among *k* boxes. These approximate the "counterintuitive moves" that make Sokoban puzzles hard for humans (Jarušek & Pelánek, 2010). |
| Novelty | `w(h)` | Ranks first the states that assign a previously unseen value to some variable among states with the same heuristic value. This diversifies the search. |

For example, the ordering `[w(h^PDB4), 4C, h^PDB4]` expands states with the largest
novelty first, breaks ties by the number of order-4 conflicts, and then by the PDB4
value. The paper's experiments show that novelty is essential and that
maximizing higher-order conflicts gives the hardest instances.

## Requirements

- A C++11 compiler (`g++` or `clang++`) and `make`
- [Boost](https://www.boost.org/) headers (header-only parts are enough)

On macOS: `brew install boost`. On Debian/Ubuntu: `sudo apt install build-essential libboost-dev`.

## Building

```bash
make
```

This produces `bin/LocalSearch`. If Boost is not on your compiler's default include path,
pass its location:

```bash
make BOOST_INC=$(brew --prefix boost)/include
```

`make clean` removes build outputs.

### Optional: PDB2 variants (Blossom V)

PDB2 pairs up the boxes so that the sum of the 2-box PDB values is as large as
possible. That is a maximum-weight perfect matching on a general (non-bipartite)
graph. The code solves it with [Blossom V](https://pub.ist.ac.at/~vnk/software.html)
by Vladimir Kolmogorov. Blossom V's license allows research and evaluation use only and
forbids redistribution, so it is not part of this repository.

To enable the PDB2 variants, build with:

```bash
make BLOSSOM=1
```

This downloads Blossom V 2.05 from the author's website into `Include/blossom5/`
(requires `curl`) and rebuilds `bin/LocalSearch` with PDB2 support. By doing so, you
accept Blossom V's license. Run plain `make` to switch back, and `make distclean` to
delete the downloaded sources. If you use a PDB2 variant in a publication, please also
cite: V. Kolmogorov, *Blossom V: A new implementation of a minimum cost perfect matching
algorithm*, Mathematical Programming Computation 1(1):43–67, 2009.

## Usage

```bash
./bin/LocalSearch <NAME> <ORDERING> <TIME> <RUN>
```

| Argument | Description |
|---|---|
| `NAME` | Maze file in `Instances/`, without the `.map` extension (e.g. `instance_01`). |
| `ORDERING` | The metric ordering that guides the search and selects the returned state. See [Orderings](#orderings). |
| `TIME` | Time limit in seconds. The paper uses `3600`. |
| `RUN` | A label for this run, such as `01`. Results go to `Results/<RUN>/`, so repeated runs don't overwrite each other. |

Example (the best-performing variant from the paper, with a 60-second limit):

```bash
./bin/LocalSearch instance_01 wpdb4r_4ocr_pdb4r 60 01
```

### Input format

Mazes use the standard Sokoban text notation: `#` wall, space floor, `@` player,
`+` player on goal, `$` box, `.` goal, and `*` box on goal. **The input must be a
goal state**, with every box already on a goal:

```
    #####
    #   #
    #   #
  ###   ##
  #      #
### # ## #   ######
#   # ## #####  **#
#               **#
##### ### #@##  **#
    #     #########
    #######
```

A file may hold several mazes separated by blank lines. Each maze may start with an
optional `!<id>` header line. Output files are labelled with the two characters after
`instance_`, so name files `instance_XX.map` to get meaningful labels.

### Output

Each run writes two files:

- `Results/<RUN>/GBFS-<ORDERING>-<TIME>/Instances/<NAME>.map` holds the generated initial
  state in the same text notation.
- `Results/<RUN>/GBFS-<ORDERING>-<TIME>/Distances/<NAME>-GBFS-<ORDERING>.txt` holds
  statistics for that state, for example:

  ```
  01 GBFS wpdb4r_4ocr_pdb4r  expanded 109560 memory 433979392 mm NA pdb1 42 mpdb2 NA mpdb3 60 mpdb4 62 time 2.0272
  ```

  The fields are: states expanded, resident memory in bytes, the minimum-matching
  lower bound (`mm`), the PDB heuristic values for patterns of 1–4 boxes, and the
  elapsed time in seconds. `mm` and `mpdb2` need Blossom V and are reported as `NA`
  unless you build with `make BLOSSOM=1`. PDB3 and PDB4 use randomly chosen patterns,
  so their values can differ between evaluations, including between this file and the
  line printed to the console.

The search also stops if the process uses more than 8 GB of memory. This limit is set in
`Source/GreedyBestFirstSearch.cpp`.

### Orderings

The `ORDERING` argument selects one of the variants evaluated in Table 1 of the paper.
An `r` suffix (`pdb3r`, `pdb4r`) marks PDBs whose patterns are chosen at random.

**Supported in the default build:**

| `ORDERING` | Paper notation | Table 1 row |
|---|---|---|
| `pdb1` | `[h^PDB1]` | 1 |
| `pdb3r` | `[h^PDB3]` | 3 |
| `pdb4r` | `[h^PDB4]` | 4 |
| `pdb4r_4ocr` | `[h^PDB4, 4C]` | 7 |
| `4ocr_pdb4r` | `[4C, h^PDB4]` | 10 |
| `wpdb1_pdb1` | `[w(h^PDB1), h^PDB1]` | 11 |
| `wpdb3r_pdb3r` | `[w(h^PDB3), h^PDB3]` | 13 |
| `wpdb4r_pdb4r` | `[w(h^PDB4), h^PDB4]` | 14 |
| `wpdb4r_pdb4r_4ocr` | `[w(h^PDB4), h^PDB4, 4C]` | 17 |
| **`wpdb4r_4ocr_pdb4r`** | **`[w(h^PDB4), 4C, h^PDB4]`** | **20** |

**`wpdb4r_4ocr_pdb4r` (row 20) is the recommended default.** It generated the hardest
states in the paper.

**Requires `make BLOSSOM=1`** (these use PDB2 directly, or through 2C or 3C conflicts,
since `3C = h^PDB3 − h^PDB2`):

| `ORDERING` | Paper notation | Table 1 row |
|---|---|---|
| `pdb2` | `[h^PDB2]` | 2 |
| `pdb2_2oc` · `pdb3r_3ocr` | `[h^PDBk, kC]`, k = 2, 3 | 5, 6 |
| `2oc_pdb2` · `3ocr_pdb3r` | `[kC, h^PDBk]`, k = 2, 3 | 8, 9 |
| `wpdb2_pdb2` | `[w(h^PDB2), h^PDB2]` | 12 |
| `wpdb2_pdb2_2oc` · `wpdb3r_pdb3r_3ocr` | `[w(h^PDBk), h^PDBk, kC]`, k = 2, 3 | 15, 16 |
| `wpbd2_2oc_pdb2` · `wpbd3r_3ocr_pdb3r` | `[w(h^PDBk), kC, h^PDBk]`, k = 2, 3 | 18, 19 |

The last two names contain the typo `wpbd`. Type them exactly as shown. The default build
rejects these orderings with an error message.

## Reproducing the paper's experiments

The paper runs every variant on the goal states of the 90 xSokoban mazes
(`Instances/instance_01.map` … `instance_90.map`), with a 1-hour limit and 8 GB of memory
per maze, and repeats each run 5 times. To run all 90 mazes locally:

```bash
# scripts/run_xsokoban.sh [ORDERING] [TIME_SECONDS] [RUN_IDS...]
scripts/run_xsokoban.sh wpdb4r_4ocr_pdb4r 3600 01 02 03 04 05
```

Scripts for PBS/Torque clusters are in `scripts/pbs/`. `submit_all.sh` submits one
`job.sh` job per (maze, ordering, run), with queue names and module versions from the
original cluster. Adjust them for yours.

The headline result ("Aggregation", row 21 of Table 1) uses 20 runs of
`wpdb4r_4ocr_pdb4r` per maze and keeps, for each maze, the state that maximizes
`[4C, h^PDB4]`. The solver of Pereira et al. (2015) solves 16.4 ± 1.3 of these 90
states on average, against 18 of the 90 human-designed xSokoban states. This repository
does not include the selection step or the solver. To reproduce the rows of Table 1 that
use PDB2, build with `make BLOSSOM=1`.

## Repository layout

```
Source/          β: backward GBFS, PDB heuristics, conflicts, novelty, instance I/O
Include/memory/  Portable memory-usage helpers
Instances/       Input mazes (see below)
scripts/         Batch-run scripts (local and PBS)
Makefile
```

Contents of `Instances/`:

- `instance_01.map` … `instance_90.map` are the goal states of the 90 xSokoban mazes and
  serve as input to β.
- `GoalxSokoban.map` contains the same 90 goal states in a single file.
- `xSokoban.map` contains the original human-designed xSokoban initial states, for
  comparison.
- `instance_01_micro.map`, `instance_01_box.map`, and `instances.map` are small mazes for
  quick tests.

## Third-party code

- **Blossom V** by Vladimir Kolmogorov is optional and not included. It is needed only for
  the PDB2 variants and the `mm` statistic. Get it from the
  [author's website](https://pub.ist.ac.at/~vnk/software.html) or with `make BLOSSOM=1`.
  See [Optional: PDB2 variants](#optional-pdb2-variants-blossom-v).
- **Memory-usage helpers** (`Include/memory/`) are by David Robert Nadeau
  (CC BY 3.0).
- **Boost** headers are used for hash containers, priority queues, and bitsets.

## Citation

If you use this code, please cite:

```bibtex
@inproceedings{bentoPL19,
  title     = {Procedural Generation of Initial States of {S}okoban},
  author    = {Damaris Bento and Andre G. Pereira and Levi H. S. Lelis},
  booktitle = {International Joint Conference on Artificial Intelligence},
  year      = {2019},
}
```
