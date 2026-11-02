# Codebase Overview – Część A (1D Optimization & Hard Cases)


---

## 1. Main Test & Entry-Point Scripts

### [test_trudne_przypadki.m](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m)
* **Definition:** Automated test runner for 6 adversarial/failure test cases (`P1`–`P6`) where individual 1D optimization methods fail while the others succeed.
* **What it does:**
  1. Creates the output folder `./wykresy_trudne_przypadki/` ([lines 19–25](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L19-L25)).
  2. Defines 6 failure scenarios in [`definicje_przypadkow`](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L119-L211).
  3. Runs all three methods on each case, classifies each outcome as `SUKCES` or `PORAŻKA`, saves six 2×2 diagnostic plots (`01_...png` to `06_...png`), one 2×3 overview plot (`00_podsumowanie_wszystkich.png`), and a summary table (`podsumowanie_wynikow.csv`).

### [Optymalizacja_CzescA.m](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m) (and [Optymalizacja1D_CzescA.mlx](file:///home/kajeko/timo/TiMO/Optymalizacja1D_CzescA.mlx))
* **Definition:** Main demonstration script for Task Part A covering standard benchmark functions (`f1`–`f4`).
* **What it does:** Plots the 4 baseline objective functions, demonstrates each algorithm individually with step-by-step iteration controls, compares convergence and active/inactive boundary constraints (`f3`), and launches the interactive GUI explorer.

---

## 2. Core Optimization Algorithms

### [uruchom_metode.m](file:///home/kajeko/timo/TiMO/uruchom_metode.m)
* **Signature:** `W = uruchom_metode(metoda, Fi, par)`
* **What it does:** Unified dispatcher that translates the constraint flag `par.ograniczenia` into bounds `[lb, ub] = [Fi.a, Fi.b]` (or `[-Inf, Inf]`) and invokes the requested algorithm (`'zloty'`, `'gradient'`, or `'powell'`).
* **Where & why called:**
  * [test_trudne_przypadki.m (line 41 & line 93)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L41): Called inside the loop over `metody = {'zloty', 'gradient', 'powell'}` so all three algorithms are executed with identical problem structures `Pi` and parameter structs `par`.
  * [Optymalizacja_CzescA.m (lines 114, 132–133)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L114): Used for the all-methods comparison table and the constrained vs. unconstrained comparison on `f3`.
  * Also called by [`pokaz_metode.m`](file:///home/kajeko/timo/TiMO/pokaz_metode.m#L4) and [`eksplorator.m`](file:///home/kajeko/timo/TiMO/eksplorator.m#L119).

### [zloty_podzial.m](file:///home/kajeko/timo/TiMO/zloty_podzial.m)
* **Signature:** `W = zloty_podzial(f, a, b, tol, maxIter)`
* **What it does:** Implements the 0th-order Golden Section Search on $[a, b]$ with reduction ratio $\tau = \frac{\sqrt{5}-1}{2} \approx 0.618$, reusing one interior evaluation per iteration and recording the full bracket history `W.hist = [a b x1 x2 f1 f2]`.
* **Where & why called:**
  * Called by [`uruchom_metode.m` (line 11)](file:///home/kajeko/timo/TiMO/uruchom_metode.m#L11) when `metoda == 'zloty'`.
  * Called by [`minimum_ref.m` (line 7)](file:///home/kajeko/timo/TiMO/minimum_ref.m#L7) with `tol = 1e-12` to polish the grid-search global minimum to high precision.

### [metoda_gradientu.m](file:///home/kajeko/timo/TiMO/metoda_gradientu.m)
* **Signature:** `W = metoda_gradientu(f, x0, alfa, tol, maxIter, lb, ub, armijo)`
* **What it does:** Implements 1D Projected Steepest Descent $x_{k+1} = P_{[lb,ub]}(x_k - \alpha_k f'(x_k))$ using central finite differences for $f'(x_k)$ and optional Armijo backtracking line search. Stops when $|f'(x_k)| < \text{tol}$ or $|x_{k+1} - x_k| < \text{tol}$.
* **Where & why called:**
  * Called by [`uruchom_metode.m` (line 13)](file:///home/kajeko/timo/TiMO/uruchom_metode.m#L13) when `metoda == 'gradient'`.

### [powell_kwadr.m](file:///home/kajeko/timo/TiMO/powell_kwadr.m)
* **Signature:** `W = powell_kwadr(f, x0, delta, tol, maxIter, lb, ub)`
* **What it does:** Implements Powell's 3-point quadratic interpolation method. Fits a parabola through $x_1 < x_2 < x_3$, jumps to its vertex $x^*$ (projected onto $[lb, ub]$) when convex ($c_2 > 0$) or takes a fallback step when concave ($c_2 \le 0$), and keeps the best 3 surrounding points.
* **Where & why called:**
  * Called by [`uruchom_metode.m` (line 15)](file:///home/kajeko/timo/TiMO/uruchom_metode.m#L15) when `metoda == 'powell'`.

---

## 3. Configuration, Test Functions & Reference Solver

### [domyslne_parametry.m](file:///home/kajeko/timo/TiMO/domyslne_parametry.m)
* **Signature:** `par = domyslne_parametry()`
* **What it does:** Returns the default struct (`tol = 1e-5`, `maxIter = 200`, `alfa = 0.1`, `armijo = true`, `delta = 0.5`, `ograniczenia = true`).
* **Where & why called:**
  * [test_trudne_przypadki.m (line 120)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L120): Called in [`definicje_przypadkow`](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L119) to initialize baseline parameters for `P1`–`P6` (with `P5` overriding `armijo = false`).
  * [Optymalizacja_CzescA.m (lines 50, 75, 96, 105, 126, 142)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L50): Initializes parameters for each section.

### [minimum_ref.m](file:///home/kajeko/timo/TiMO/minimum_ref.m)
* **Signature:** `[xr, fr] = minimum_ref(Fi)`
* **What it does:** Computes the ground-truth global minimum $(x_{\text{ref}}, f_{\text{ref}})$ on $[a, b]$ by evaluating `Fi.f` on a dense 20,001-point grid, refining the best sub-interval with [`zloty_podzial`](file:///home/kajeko/timo/TiMO/zloty_podzial.m) (`tol = 1e-12`), and checking both endpoints `Fi.a` and `Fi.b`.
* **Where & why called:**
  * [test_trudne_przypadki.m (line 36)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L36): Computes the exact reference solution `xr` for each test case `Pi` to measure error `|W.xopt - xr|` and **decide whether a method succeeded (`blad_x < 5e-2`) or failed.**
  * [Optymalizacja_CzescA.m (lines 24, 111)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L24), [`pokaz_metode.m` (line 5)](file:///home/kajeko/timo/TiMO/pokaz_metode.m#L5), and [`eksplorator.m` (line 120)](file:///home/kajeko/timo/TiMO/eksplorator.m#L120).

### [funkcje_testowe.m](file:///home/kajeko/timo/TiMO/funkcje_testowe.m)
* **Signature:** `F = funkcje_testowe()`
* **What it does:** Defines the 4 standard benchmark functions (`f1` unimodal, `f2` multimodal, `f3` boundary minimum, `f4` non-differentiable).
* **Where & why called:**
  * Called across [Optymalizacja_CzescA.m (lines 13, 49, 74, 95, 104, 141)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L13) and [`eksplorator.m` (line 4)](file:///home/kajeko/timo/TiMO/eksplorator.m#L4).

### [wartosci.m](file:///home/kajeko/timo/TiMO/wartosci.m)
* **Signature:** `y = wartosci(f, x)`
* **What it does:** Evaluates objective function handle `f` on vector `x`, falling back to `arrayfun` if `f` does not use element-wise operators (`.^`, `.*`).
  
  **Bla bla bla, in general this is a plotting helper**


* **Where & why called:**
  * Called by [`minimum_ref.m` (line 4)](file:///home/kajeko/timo/TiMO/minimum_ref.m#L4), [`rysuj_metode.m` (line 9)](file:///home/kajeko/timo/TiMO/rysuj_metode.m#L9), [`rysuj_wszystkie.m` (line 9)](file:///home/kajeko/timo/TiMO/rysuj_wszystkie.m#L9), and [Optymalizacja_CzescA.m (line 19)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L19) for safe curve plotting.

---

## 4. Visualization & UI Modules

### [rysuj_metode.m](file:///home/kajeko/timo/TiMO/rysuj_metode.m)
* **Signature:** `rysuj_metode(ax, Fi, W, k, par, dopisek)`
* **What it does:** Draws the algorithm-specific diagnostic plot at iteration `k` on axes `ax`:
  * For `'zloty'`: plots nested interval bars $[a_i, b_i]$ beneath $f(x)$ and interior test points $x_1, x_2$.
  * For `'gradient'`: plots the iterate path $x_0 \to x_k$ and the red tangent line with slope $f'(x_k)$.
  * For `'powell'`: plots the interpolating parabolas $q(x)$ from previous and current iterations and the vertex $x^*$.
* **Where & why called:**
  * [test_trudne_przypadki.m (line 72)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L72): Draws the first 3 tiles of each 2×2 failure-case figure (`W.iter` final state) with the `[SUKCES]` / `[PORAŻKA]` subtitle (`dopisek`).
  * [Optymalizacja_CzescA.m (lines 134–135)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L134-L135), [`pokaz_metode.m` (lines 9–10)](file:///home/kajeko/timo/TiMO/pokaz_metode.m#L9-L10), and [`eksplorator.m` (line 154)](file:///home/kajeko/timo/TiMO/eksplorator.m#L154).

### [rysuj_zbieznosc.m](file:///home/kajeko/timo/TiMO/rysuj_zbieznosc.m)
* **Signature:** `rysuj_zbieznosc(ax, Ws, xref, k)`
* **What it does:** Plots the error $\lvert x_k - x_{\text{ref}} \rvert$ on a logarithmic y-scale as a function of iteration $k$ for one or more result structs `Ws`.
* **Where & why called:**
  * [test_trudne_przypadki.m (line 76)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L76): Draws the bottom-right tile (Tile 4) of each 2×2 case figure, comparing the error decay of all 3 methods on the same axes.
  * [Optymalizacja_CzescA.m (line 119)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L119), [`pokaz_metode.m` (line 11)](file:///home/kajeko/timo/TiMO/pokaz_metode.m#L11), and [`eksplorator.m` (line 158)](file:///home/kajeko/timo/TiMO/eksplorator.m#L158).

### [rysuj_wszystkie.m](file:///home/kajeko/timo/TiMO/rysuj_wszystkie.m)
* **Signature:** `rysuj_wszystkie(ax, Fi, Ws, k, par)`
* **What it does:** Overlays the iteration paths and final points $x_k$ of all three methods on top of $f(x)$ in a single plot.
* **Where & why called:**
  * [test_trudne_przypadki.m (line 96)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L96): Generates each of the 6 tiles in the summary figure `00_podsumowanie_wszystkich.png`.
  * [`eksplorator.m` (line 156)](file:///home/kajeko/timo/TiMO/eksplorator.m#L156): Used when `"Wszystkie trzy"` is selected in the GUI dropdown.

### [pokaz_metode.m](file:///home/kajeko/timo/TiMO/pokaz_metode.m)
* **Signature:** `W = pokaz_metode(Fi, metoda, k, par)`
* **What it does:** Convenience wrapper for single-method sections: runs one method, opens a 2×2 figure (state at iteration `k`, final state, and convergence curve), and prints a summary to the Command Window.
* **Where & why called:**
  * Called in Sections 2, 3, and 4 of [Optymalizacja_CzescA.m (lines 53, 79, 100)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L53).

### [eksplorator.m](file:///home/kajeko/timo/TiMO/eksplorator.m)
* **Signature:** `fig = eksplorator(F, par)`
* **What it does:** Builds the interactive `uifigure` application allowing live selection of test or custom functions, parameters, iteration slider scrubbing, and step-by-step animation.
* **Where & why called:**
  * Called in Section 6 of [Optymalizacja_CzescA.m (line 142)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L142).

---

## 5. Standalone Golden Section Subfolder (`zloty_podzial/`)

* [zloty_podzial/zloty_podzial.m](file:///home/kajeko/timo/TiMO/zloty_podzial/zloty_podzial.m): Standalone Golden Section function returning `[xmin, fmin, iter, epsilon]` (without plotting history struct).
* [zloty_podzial/test_zloty_podzial.m](file:///home/kajeko/timo/TiMO/zloty_podzial/test_zloty_podzial.m): Console table test suite testing 10 interval configurations on [`f_unimodalna.m`](file:///home/kajeko/timo/TiMO/zloty_podzial/f_unimodalna.m) and [`f_multimodalna.m`](file:///home/kajeko/timo/TiMO/zloty_podzial/f_multimodalna.m).
