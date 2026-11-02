# Przegląd bazy kodu – Część A (Optymalizacja 1D i trudne przypadki)


## 1. Główne skrypty testowe i punkty wejścia

### [test_trudne_przypadki.m](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m)
* **Definicja:** Zautomatyzowane narzędzie testowe dla 6 trudnych/nieudanych przypadków testowych (`P1`–`P6`), w których poszczególne metody optymalizacji 1D zawodzą, podczas gdy inne kończą się sukcesem.
* **Co robi:**
  1. Tworzy folder wyjściowy `./wykresy_trudne_przypadki/` ([linie 19–25](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L19-L25)).
  2. Definiuje 6 scenariuszy niepowodzeń w [`definicje_przypadkow`](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L119-L211).
  3. Uruchamia wszystkie trzy metody dla każdego przypadku, klasyfikuje każdy wynik jako `SUKCES` lub `PORAŻKA`, zapisuje sześć wykresów diagnostycznych 2×2 (od `01_...png` do `06_...png`), jeden wykres poglądowy 2×3 (`00_podsumowanie_wszystkich.png`) oraz tabelę podsumowującą (`podsumowanie_wynikow.csv`).

### [Optymalizacja_CzescA.m](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m) (oraz [Optymalizacja1D_CzescA.mlx](file:///home/kajeko/timo/TiMO/Optymalizacja1D_CzescA.mlx))
* **Definicja:** Główny skrypt demonstracyjny dla Części A zadania, obejmujący standardowe funkcje testowe (`f1`–`f4`).
* **Co robi:** Rysuje 4 bazowe funkcje celu, demonstruje każdy algorytm z osobna z możliwością kontrolowania iteracji krok po kroku, porównuje zbieżność i aktywne/nieaktywne ograniczenia brzegowe (`f3`) oraz uruchamia interaktywny eksplorator GUI.

---

## 2. Główne algorytmy optymalizacji

### [uruchom_metode.m](file:///home/kajeko/timo/TiMO/uruchom_metode.m)
* **Sygnatura:** `W = uruchom_metode(metoda, Fi, par)`
* **Co robi:** Zunifikowany dyspozytor, który tłumaczy flagę ograniczeń `par.ograniczenia` na granice `[lb, ub] = [Fi.a, Fi.b]` (lub `[-Inf, Inf]`) i wywołuje żądany algorytm (`'zloty'`, `'gradient'` lub `'powell'`).
* **Gdzie i dlaczego jest wywoływany:**
  * [test_trudne_przypadki.m (linia 41 i linia 93)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L41): Wywoływany wewnątrz pętli dla `metody = {'zloty', 'gradient', 'powell'}`, dzięki czemu wszystkie trzy algorytmy są wykonywane z identycznymi strukturami problemu `Pi` i strukturami parametrów `par`.
  * [Optymalizacja_CzescA.m (linie 114, 132–133)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L114): Używany do tabeli porównawczej wszystkich metod oraz porównania z ograniczeniami i bez ograniczeń dla `f3`.
  * Wywoływany również przez [`pokaz_metode.m`](file:///home/kajeko/timo/TiMO/pokaz_metode.m#L4) i [`eksplorator.m`](file:///home/kajeko/timo/TiMO/eksplorator.m#L119).

### [zloty_podzial.m](file:///home/kajeko/timo/TiMO/zloty_podzial.m)
* **Sygnatura:** `W = zloty_podzial(f, a, b, tol, maxIter)`
* **Co robi:** Implementuje metodę złotego podziału (rzędu zerowego) na przedziale $[a, b]$ ze współczynnikiem redukcji $\tau = \frac{\sqrt{5}-1}{2} \approx 0.618$, wykorzystując ponownie jedno obliczenie wewnątrz przedziału w każdej iteracji i zapisując pełną historię przedziałów `W.hist = [a b x1 x2 f1 f2]`.
* **Gdzie i dlaczego jest wywoływany:**
  * Wywoływany przez [`uruchom_metode.m` (linia 11)](file:///home/kajeko/timo/TiMO/uruchom_metode.m#L11), gdy `metoda == 'zloty'`.
  * Wywoływany przez [`minimum_ref.m` (linia 7)](file:///home/kajeko/timo/TiMO/minimum_ref.m#L7) z `tol = 1e-12` w celu dopracowania globalnego minimum z przeszukiwania siatki do wysokiej precyzji.

### [metoda_gradientu.m](file:///home/kajeko/timo/TiMO/metoda_gradientu.m)
* **Sygnatura:** `W = metoda_gradientu(f, x0, alfa, tol, maxIter, lb, ub, armijo)`
* **Co robi:** Implementuje jednowymiarową rzutowaną metodę najszybszego spadku $x_{k+1} = P_{[lb,ub]}(x_k - \alpha_k f'(x_k))$, wykorzystującą centralne różnice skończone dla $f'(x_k)$ oraz opcjonalne wyszukiwanie kierunkowe Armijo z nawrotami. Zatrzymuje się, gdy $|f'(x_k)| < \text{tol}$ lub $|x_{k+1} - x_k| < \text{tol}$.
* **Gdzie i dlaczego jest wywoływany:**
  * Wywoływany przez [`uruchom_metode.m` (linia 13)](file:///home/kajeko/timo/TiMO/uruchom_metode.m#L13), gdy `metoda == 'gradient'`.

### [powell_kwadr.m](file:///home/kajeko/timo/TiMO/powell_kwadr.m)
* **Sygnatura:** `W = powell_kwadr(f, x0, delta, tol, maxIter, lb, ub)`
* **Co robi:** Implementuje 3-punktową metodę interpolacji kwadratowej Powella. Dopasowuje parabolę przechodzącą przez $x_1 < x_2 < x_3$, przeskakuje do jej wierzchołka $x^*$ (rzutowanego na $[lb, ub]$), gdy jest wypukła ($c_2 > 0$), lub wykonuje krok rezerwowy, gdy jest wklęsła ($c_2 \le 0$), i zachowuje 3 najlepsze sąsiednie punkty.
* **Gdzie i dlaczego jest wywoływany:**
  * Wywoływany przez [`uruchom_metode.m` (linia 15)](file:///home/kajeko/timo/TiMO/uruchom_metode.m#L15), gdy `metoda == 'powell'`.

---

## 3. Konfiguracja, funkcje testowe i solver referencyjny

### [domyslne_parametry.m](file:///home/kajeko/timo/TiMO/domyslne_parametry.m)
* **Sygnatura:** `par = domyslne_parametry()`
* **Co robi:** Zwraca domyślną strukturę (`tol = 1e-5`, `maxIter = 200`, `alfa = 0.1`, `armijo = true`, `delta = 0.5`, `ograniczenia = true`).
* **Gdzie i dlaczego jest wywoływany:**
  * [test_trudne_przypadki.m (linia 120)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L120): Wywoływany w [`definicje_przypadkow`](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L119) w celu zainicjowania parametrów bazowych dla `P1`–`P6` (przy czym `P5` nadpisuje `armijo = false`).
  * [Optymalizacja_CzescA.m (linie 50, 75, 96, 105, 126, 142)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L50): Inicjuje parametry dla każdej sekcji.

### [minimum_ref.m](file:///home/kajeko/timo/TiMO/minimum_ref.m)
* **Sygnatura:** `[xr, fr] = minimum_ref(Fi)`
* **Co robi:** Oblicza rzeczywiste minimum globalne $(x_{\text{ref}}, f_{\text{ref}})$ na $[a, b]$ poprzez ewaluację `Fi.f` na gęstej siatce 20 001 punktów, dopracowując najlepszy podprzedział za pomocą [`zloty_podzial`](file:///home/kajeko/timo/TiMO/zloty_podzial.m) (`tol = 1e-12`) i sprawdzając oba punkty końcowe `Fi.a` oraz `Fi.b`.
* **Gdzie i dlaczego jest wywoływany:**
  * [test_trudne_przypadki.m (linia 36)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L36): Oblicza dokładne rozwiązanie referencyjne `xr` dla każdego przypadku testowego `Pi`, aby zmierzyć błąd $\lvert W.xopt - xr \rvert$ i **zdecydować, czy metoda zakończyła się sukcesem (`blad_x < 5e-2`), czy poniosła porażkę**.
  * [Optymalizacja_CzescA.m (linie 24, 111)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L24), [`pokaz_metode.m` (linia 5)](file:///home/kajeko/timo/TiMO/pokaz_metode.m#L5) oraz [`eksplorator.m` (linia 120)](file:///home/kajeko/timo/TiMO/eksplorator.m#L120).

### [funkcje_testowe.m](file:///home/kajeko/timo/TiMO/funkcje_testowe.m)
* **Sygnatura:** `F = funkcje_testowe()`
* **Co robi:** Definiuje 4 standardowe funkcje testowe (`f1` jednomodalna, `f2` wielomodalna, `f3` minimum brzegowe, `f4` nieróżniczkowalna).
* **Gdzie i dlaczego jest wywoływany:**
  * Wywoływany w skryptach [Optymalizacja_CzescA.m (linie 13, 49, 74, 95, 104, 141)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L13) i [`eksplorator.m` (linia 4)](file:///home/kajeko/timo/TiMO/eksplorator.m#L4).

### [wartosci.m](file:///home/kajeko/timo/TiMO/wartosci.m)
* **Sygnatura:** `y = wartosci(f, x)`
* **Co robi:** Oblicza wartość uchwytu funkcji celu `f` dla wektora `x`, używając awaryjnie `arrayfun`, jeśli `f` nie wykorzystuje operatorów elementarnych (`.^`, `.*`).
  
  **Bla bla bla, ogólnie rzecz biorąc, jest to funkcja pomocnicza do rysowania**

* **Gdzie i dlaczego jest wywoływany:**
  * Wywoływany przez [`minimum_ref.m` (linia 4)](file:///home/kajeko/timo/TiMO/minimum_ref.m#L4), [`rysuj_metode.m` (linia 9)](file:///home/kajeko/timo/TiMO/rysuj_metode.m#L9), [`rysuj_wszystkie.m` (linia 9)](file:///home/kajeko/timo/TiMO/rysuj_wszystkie.m#L9) oraz [Optymalizacja_CzescA.m (linia 19)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L19) w celu bezpiecznego kreślenia krzywych.

---

## 4. Moduły wizualizacji i interfejsu użytkownika (UI)

### [rysuj_metode.m](file:///home/kajeko/timo/TiMO/rysuj_metode.m)
* **Sygnatura:** `rysuj_metode(ax, Fi, W, k, par, dopisek)`
* **Co robi:** Rysuje specyficzny dla algorytmu wykres diagnostyczny w iteracji `k` na osiach `ax`:
  * Dla `'zloty'`: rysuje zagnieżdżone słupki przedziałów $[a_i, b_i]$ pod $f(x)$ oraz wewnętrzne punkty testowe $x_1, x_2$.
  * Dla `'gradient'`: rysuje ścieżkę iteracji $x_0 \to x_k$ oraz czerwoną linię stycznej o nachyleniu $f'(x_k)$.
  * Dla `'powell'`: rysuje parabole interpolujące $q(x)$ z poprzedniej i bieżącej iteracji oraz wierzchołek $x^*$.
* **Gdzie i dlaczego jest wywoływany:**
  * [test_trudne_przypadki.m (linia 72)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L72): Rysuje pierwsze 3 kafelki każdej figury 2×2 dla przypadków niepowodzeń (stan końcowy `W.iter`) z podtytułem `[SUKCES]` / `[PORAŻKA]` (`dopisek`).
  * [Optymalizacja_CzescA.m (linie 134–135)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L134-L135), [`pokaz_metode.m` (linie 9–10)](file:///home/kajeko/timo/TiMO/pokaz_metode.m#L9-L10) i [`eksplorator.m` (linia 154)](file:///home/kajeko/timo/TiMO/eksplorator.m#L154).

### [rysuj_zbieznosc.m](file:///home/kajeko/timo/TiMO/rysuj_zbieznosc.m)
* **Sygnatura:** `rysuj_zbieznosc(ax, Ws, xref, k)`
* **Co robi:** Rysuje błąd $\lvert x_k - x_{\text{ref}} \rvert$ w logarytmicznej skali osi Y w funkcji iteracji $k$ dla jednej lub większej liczby struktur wyników `Ws`.
* **Gdzie i dlaczego jest wywoływany:**
  * [test_trudne_przypadki.m (linia 76)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L76): Rysuje prawy dolny kafelek (Kafelek 4) każdej figury 2×2 przypadku, porównując spadek błędu wszystkich 3 metod na tych samych osiach.
  * [Optymalizacja_CzescA.m (linia 119)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L119), [`pokaz_metode.m` (linia 11)](file:///home/kajeko/timo/TiMO/pokaz_metode.m#L11) i [`eksplorator.m` (linia 158)](file:///home/kajeko/timo/TiMO/eksplorator.m#L158).

### [rysuj_wszystkie.m](file:///home/kajeko/timo/TiMO/rysuj_wszystkie.m)
* **Sygnatura:** `rysuj_wszystkie(ax, Fi, Ws, k, par)`
* **Co robi:** Nakłada ścieżki iteracji i punkty końcowe $x_k$ wszystkich trzech metod na wykres $f(x)$ na jednym rysunku.
* **Gdzie i dlaczego jest wywoływany:**
  * [test_trudne_przypadki.m (linia 96)](file:///home/kajeko/timo/TiMO/test_trudne_przypadki.m#L96): Generuje każdy z 6 kafelków na zbiorczej figurze podsumowującej `00_podsumowanie_wszystkich.png`.
  * [`eksplorator.m` (linia 156)](file:///home/kajeko/timo/TiMO/eksplorator.m#L156): Używany, gdy w rozwijanym menu GUI wybrano `"Wszystkie trzy"`.

### [pokaz_metode.m](file:///home/kajeko/timo/TiMO/pokaz_metode.m)
* **Sygnatura:** `W = pokaz_metode(Fi, metoda, k, par)`
* **Co robi:** Wygodny wrapper dla sekcji pojedynczych metod: uruchamia jedną metodę, otwiera okno 2×2 (stan w iteracji `k`, stan końcowy oraz krzywa zbieżności) i wypisuje podsumowanie w Command Window.
* **Gdzie i dlaczego jest wywoływany:**
  * Wywoływany w sekcjach 2, 3 i 4 skryptu [Optymalizacja_CzescA.m (linie 53, 79, 100)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L53).

### [eksplorator.m](file:///home/kajeko/timo/TiMO/eksplorator.m)
* **Sygnatura:** `fig = eksplorator(F, par)`
* **Co robi:** Tworzy interaktywną aplikację `uifigure` pozwalającą na wybór funkcji testowych lub własnych na żywo, zmianę parametrów, przewijanie iteracji suwakiem oraz animację krok po kroku.
* **Gdzie i dlaczego jest wywoływany:**
  * Wywoływany w sekcji 6 skryptu [Optymalizacja_CzescA.m (linia 142)](file:///home/kajeko/timo/TiMO/Optymalizacja_CzescA.m#L142).

---

## 5. Podfolder samodzielnej metody złotego podziału (`zloty_podzial/`)

* [zloty_podzial/zloty_podzial.m](file:///home/kajeko/timo/TiMO/zloty_podzial/zloty_podzial.m): Samodzielna funkcja złotego podziału zwracająca `[xmin, fmin, iter, epsilon]` (bez struktury historii do rysowania).
* [zloty_podzial/test_zloty_podzial.m](file:///home/kajeko/timo/TiMO/zloty_podzial/test_zloty_podzial.m): Konsolowy zestaw testów w formie tabeli testujący 10 konfiguracji przedziałów na plikach [`f_unimodalna.m`](file:///home/kajeko/timo/TiMO/zloty_podzial/f_unimodalna.m) i [`f_multimodalna.m`](file:///home/kajeko/timo/TiMO/zloty_podzial/f_multimodalna.m).