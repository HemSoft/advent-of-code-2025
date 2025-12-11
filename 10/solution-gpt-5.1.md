# Day 10 - GPT-5.1

| Language   | Part 1 | Part 2 |
|------------|--------|--------|
| dotnet     | 399    | 15631  |
| powershell | 399    | 15631  |
| go         | 399    | 15631  |
| typescript | 399    | 15631  |
| rust       | 399    | 15631  |
| python     | 399    | 15631  |
| elixir     | 399    | 15631  |
| rhombus    | 399    | 15631  |

## Part 2 – Joltage counters

Each machine line also includes a list of **joltage counters** in `{...}`. There is one counter per light position. Every button is wired to some set of indices; in Part 2, pressing a button:

- toggles the corresponding indicator lights (as in Part 1), and
- **adds 1** to each joltage counter whose index appears in that button’s wiring.

For a given machine, let:

- $m$ = number of counters (and light positions), indexed $i = 0,\dots,m-1$,
- $n$ = number of buttons, indexed $j = 0,\dots,n-1$,
- $t_i$ = required final joltage of counter $i$ (from the `{...}` list),
- $S_j \subseteq \{0,\dots,m-1\}$ = set of indices incremented by button $j$,
- $x_j \in \mathbb{Z}_{\ge 0}$ = how many times we press button $j$.

Pressing button $j$ once contributes 1 unit of joltage to every counter in $S_j$. Starting from all counters at 0, the constraints are:

$$\forall i:\quad \sum_{j: i \in S_j} x_j = t_i.$$

Our objective is to minimize the **total number of button presses**:

$$\min \sum_{j=0}^{n-1} x_j \quad \text{subject to the equalities above and } x_j \in \mathbb{Z}_{\ge 0}.$$

Equivalently, if we define an $m\times n$ matrix $A$ with

$$A_{ij} = \begin{cases}
1 & \text{if } i \in S_j,\\
0 & \text{otherwise,}
\end{cases}$$

and let $x$ be the vector of button press counts and $b$ the vector of target joltages, then Part 2 for one machine is:

$$\min 1^\top x \quad \text{s.t. } A x = b,\; x \in \mathbb{Z}_{\ge 0}.$$

Solving strategy used in practice:

- Treat each machine independently; parse its targets and button sets.
- Build $A$ and $b$ as above.
- Use a small **integer linear programming (ILP)** / mixed‑integer solver to find the minimum‑cost integer solution $x$.
- Sum the optimal objective values over all machines to get the puzzle answer.

Why ILP works well here:

- The number of counters and buttons per machine is tiny (on the order of at most 10–15 each in the real input), so $A$ is a very small 0–1 matrix.
- Target joltages are also modest (tens to low hundreds), so feasible solutions use a relatively small total number of presses.
- The constraints are pure equalities with non‑negative unit coefficients, which makes the search space well‑behaved for branch‑and‑bound–style ILP solvers.
- The problem guarantees that each machine is solvable (there exists at least one non‑negative integer solution), and we only care about the minimal‑press one.

Alternative views / approaches:

- You can see this as a multi‑dimensional “coin change” problem: each button is a coin whose “value” vector is its contributions to each counter; we must exactly reach the target vector with as few coins as possible.
- Some solutions instead run a best‑first search (e.g. A*) over the state space of counter vectors, using a heuristic like the sum of remaining deficits. This also works because the dimensions and target values are small, but ILP gives a cleaner and more direct formulation.

In summary, Part 2 is a tiny ILP per machine with equality constraints $Ax=b$ and objective $\min 1^\top x$, solved independently and summed.
