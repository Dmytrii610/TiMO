%% Teoria i Metody Optymalizacji – Część A: minimalizacja funkcji jednej zmiennej
% Skrypt realizuje część A zadania projektowego: trzy algorytmy minimalizacji funkcji jednej zmiennej – *(i) metodę złotego podziału*, *(ii) metodę gradientu* i *(iii) metodę aproksymacji kwadratowej Powella* – przetestowane na czterech funkcjach celu, w tym na „trudnych przypadkach”: funkcji multimodalnej, minimum leżącym na ograniczeniu i funkcji nieróżniczkowalnej w minimum.
% *Jak korzystać.* Uruchom cały skrypt (*Run*, F5). Każda sekcja metody ma własne kontrolki – listę funkcji, parametry metody i suwak iteracji *k*. Zmiana kontrolki automatycznie przelicza i przerysowuje tylko tę sekcję. Lewy górny wykres pokazuje stan algorytmu po *k* iteracjach, prawy – stan końcowy, dolny – zbieżność. Sekcja 6 otwiera osobne okno eksploratora z animacją i możliwością wpisania własnej funkcji.
% Funkcje algorytmów i wizualizacji znajdują się w osobnych plikach .m w tym samym folderze (MATLAB R2019b lub nowszy).

%% 1. Funkcje celu
% Zestaw testowy. Przedział $[a,b]$ jest jednocześnie ograniczeniem $x \in [a,b]$.
% • *f1 – unimodalna:* $f_1(x) = (x-2)^2 + 0.5\,e^{0.3x}$, $x\in[-1,\,5]$ – przypadek „łatwy”, ograniczenia nieaktywne.
% • *f2 – multimodalna:* $f_2(x) = x^4 - 4x^2 + x$, $x\in[-2.5,\,2.5]$ – minimum globalne $x\approx-1.47$ i lokalne $x\approx1.35$.
% • *f3 – minimum na ograniczeniu:* $f_3(x) = (x-4)^2 + \sin 2x$, $x\in[0,\,3]$ – minima bez ograniczeń ($x\approx3.03$ i $x\approx4.92$) leżą poza przedziałem, rozwiązaniem jest brzeg $x = 3$.
% • *f4 – nieróżniczkowalna:* $f_4(x) = |x-1| + 0.3x^2$, $x\in[-2,\,3]$ – minimum $x = 1$ w punkcie załamania, w którym pochodna nie istnieje.
% Zielone pole to zbiór dopuszczalny $[a,b]$, gwiazdka – minimum referencyjne (globalne na $[a,b]$, wyznaczone na gęstej siatce i doprecyzowane), kwadrat – domyślny punkt startowy $x_0$ dla gradientu i metody Powella.
F = funkcje_testowe();
figure('Name', 'Funkcje celu', 'Color', 'w', 'Position', [100 100 1100 750]);
t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for i = 1:numel(F)
    ax = nexttile(t);  hold(ax, 'on');  grid(ax, 'on');  box(ax, 'on');
    xx = linspace(F(i).xplot(1), F(i).xplot(2), 800);
    yy = wartosci(F(i).f, xx);
    yl = [min(yy) max(yy)] + [-0.05 0.05]*(max(yy) - min(yy));
    patch(ax, [F(i).a F(i).b F(i).b F(i).a], yl([1 1 2 2]), [0.3 0.75 0.3], ...
          'FaceAlpha', 0.12, 'EdgeColor', 'none');
    plot(ax, xx, yy, 'k-', 'LineWidth', 1.5);
    [xr, fr] = minimum_ref(F(i));
    plot(ax, xr, fr, 'p', 'MarkerSize', 14, 'MarkerFaceColor', [0.9 0.2 0.2], 'MarkerEdgeColor', 'k');
    plot(ax, F(i).x0, F(i).f(F(i).x0), 's', 'MarkerSize', 8, ...
         'MarkerFaceColor', [0.2 0.6 0.2], 'MarkerEdgeColor', 'k');
    hold(ax, 'off');  xlim(ax, F(i).xplot);  ylim(ax, yl);
    title(ax, {F(i).nazwa, ['f(x) = ' F(i).wzor]});
    legend(ax, {'[a, b]', 'f(x)', sprintf('min: x = %.4f', xr), 'x_0'}, 'Location', 'best');
end

%% 2. Metoda złotego podziału
% Metoda bezgradientowa dla funkcji unimodalnej na $[a,b]$. W przedziale wybiera się dwa punkty
%
% $$x_1 = b - \tau(b-a),\qquad x_2 = a + \tau(b-a),\qquad \tau = \frac{\sqrt{5}-1}{2}\approx 0.618$$
%
% Jeśli $f(x_1) > f(x_2)$, minimum leży w $[x_1,\,b]$, w przeciwnym razie w $[a,\,x_2]$. Dzięki proporcji złotego podziału jeden z punktów przechodzi do następnej iteracji, więc na iterację przypada tylko *jedno* nowe obliczenie $f$, a przedział maleje $\tau$-krotnie:
%
% $$b_k - a_k = \tau^k\,(b_0-a_0)\quad\Rightarrow\quad k \ge \frac{\ln\left(\mathrm{tol}/(b_0-a_0)\right)}{\ln\tau}$$
%
% Ograniczenie $x\in[a,b]$ jest spełnione z definicji metody. Dla funkcji multimodalnej metoda znajduje *któreś* minimum lokalne – które, zależy od przedziału (sprawdź f2 z przedziałem `[-1 2.5]`).
% *Na wykresie:* poziome paski pod krzywą to kolejne przedziały $[a_k,\,b_k]$ (od jasnych do ciemnych), żółte pole – bieżący przedział, kółko i kwadrat – punkty $x_1$, $x_2$, gwiazdka – najlepszy punkt.
nrF = 2;   % funkcja celu  [kontrolka: lista – 1 = f1: unimodalna, 2 = f2: multimodalna, 3 = f3: minimum na ograniczeniu, 4 = f4: nieróżniczkowalna]
ab  = [];   % własny przedział [a b]; [] = domyślny z definicji funkcji  [kontrolka]
tol = 1e-5;   % tolerancja = końcowa długość przedziału  [kontrolka: lista – 1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-8]
k   = 3;   % iteracja pokazana na lewym wykresie  [kontrolka: suwak 0…40]

if ~exist('F', 'var'), F = funkcje_testowe(); end
par = domyslne_parametry();   par.tol = tol;
Fi  = F(nrF);
if numel(ab) == 2, Fi.a = min(ab);  Fi.b = max(ab); end
Wz  = pokaz_metode(Fi, 'zloty', k, par);

%% 3. Metoda gradientu
% Metoda najszybszego spadku w 1D – krok w kierunku przeciwnym do pochodnej. Dla zadania z ograniczeniami stosowany jest *gradient rzutowany*:
%
% $$x_{k+1} = P_{[a,b]}\left(x_k - \alpha_k f'(x_k)\right),\qquad P_{[a,b]}(x) = \min\left(\max(x,a),\,b\right)$$
%
% Pochodna liczona jest numerycznie różnicą centralną $f'(x)\approx\frac{f(x+h)-f(x-h)}{2h}$, więc metoda działa dla dowolnej funkcji (koszt: 2 obliczenia $f$ na pochodną). Długość kroku jest stała ($\alpha_k=\alpha$) albo dobierana metodą *backtracking* – krok jest połowiony, dopóki nie zachodzi warunek Armijo:
%
% $$f(x_{k+1}) \le f(x_k) + c_1\, f'(x_k)\,(x_{k+1}-x_k),\qquad c_1 = 10^{-4}$$
%
% Kryteria stopu: $|f'(x_k)| < \mathrm{tol}$ albo $|x_{k+1}-x_k| < \mathrm{tol}$. Drugie wykrywa także minimum na ograniczeniu, gdzie pochodna jest niezerowa, ale rzut zatrzymuje ruch.
% *Warto sprawdzić:* f2 ze startem `x0 = 0.5` i `x0 = -0.5` (dwa różne minima); f4 bez Armijo (oscylacje wokół załamania); f2 bez Armijo z $\alpha = 0.3$ (za duży krok – brak zbieżności); f3 bez ograniczeń (wyjście poza $[0,3]$).
% *Na wykresie:* kolejne punkty $x_k$ (od jasnych do ciemnych), czerwona styczna o nachyleniu $f'(x_k)$.
nrF    = 2;   % funkcja celu  [kontrolka: lista – 1 = f1: unimodalna, 2 = f2: multimodalna, 3 = f3: minimum na ograniczeniu, 4 = f4: nieróżniczkowalna]
x0     = [];   % punkt startowy; [] = domyślny  [kontrolka]
alfa   = 0.1;   % krok (przy Armijo: krok początkowy)  [kontrolka: suwak 0.01…0.6]
armijo = true;   % dobór kroku warunkiem Armijo  [kontrolka]
ogr    = true;   % ograniczenia a <= x <= b  [kontrolka]
k      = 3;   % iteracja pokazana na lewym wykresie  [kontrolka: suwak 0…60]

if ~exist('F', 'var'), F = funkcje_testowe(); end
par = domyslne_parametry();
par.alfa = alfa;   par.armijo = armijo;   par.ograniczenia = ogr;
Fi = F(nrF);
if isscalar(x0), Fi.x0 = x0; end
Wg = pokaz_metode(Fi, 'gradient', k, par);

%% 4. Metoda aproksymacji kwadratowej Powella
% Funkcję przybliża się parabolą przechodzącą przez trzy punkty, a za nowy punkt przyjmuje wierzchołek paraboli. Punkty startowe: $x_1 = x_0$, $x_2 = x_1 + \Delta$, a $x_3 = x_1 + 2\Delta$, gdy $f(x_2)\le f(x_1)$, w przeciwnym razie $x_3 = x_1 - \Delta$. Dla uporządkowanych punktów $x_1 < x_2 < x_3$:
%
% $$c_1 = \frac{f_2-f_1}{x_2-x_1},\qquad c_2 = \frac{1}{x_3-x_2}\left(\frac{f_3-f_1}{x_3-x_1} - c_1\right),\qquad x^* = \frac{x_1+x_2}{2} - \frac{c_1}{2c_2}$$
%
% Z czterech punktów $\{x_1, x_2, x_3, x^*\}$ zostaje najlepszy i jego dwaj sąsiedzi, co utrzymuje minimum „w okrążeniu”. Zabezpieczenia: gdy $c_2 \le 0$ (parabola wklęsła – wierzchołek byłby maksimum), wykonywany jest krok w stronę mniejszych wartości $f$; przy ograniczeniach $x^*$ jest rzutowany na $[a,b]$. Kryterium stopu: $|x^* - x_{best}| < \mathrm{tol}$.
% Dla funkcji gładkich metoda zbiega nadliniowo (kilka iteracji), ale traci tę zaletę, gdy parabola źle przybliża funkcję – np. f4 z załamaniem w minimum.
% *Na wykresie:* pomarańczowa parabola z bieżącej iteracji, blade – z poprzednich, gwiazdka – nowy punkt $x^*$.
nrF   = 2;   % funkcja celu  [kontrolka: lista – 1 = f1: unimodalna, 2 = f2: multimodalna, 3 = f3: minimum na ograniczeniu, 4 = f4: nieróżniczkowalna]
x0    = [];   % punkt startowy; [] = domyślny  [kontrolka]
delta = 0.5;   % krok startowy  [kontrolka: suwak 0.05…2]
ogr   = true;   % ograniczenia a <= x <= b  [kontrolka]
k     = 3;   % iteracja pokazana na lewym wykresie  [kontrolka: suwak 0…30]

if ~exist('F', 'var'), F = funkcje_testowe(); end
par = domyslne_parametry();
par.delta = delta;   par.ograniczenia = ogr;
Fi = F(nrF);
if isscalar(x0), Fi.x0 = x0; end
Wp = pokaz_metode(Fi, 'powell', k, par);

%% 5. Porównanie metod na wszystkich funkcjach
% Wszystkie trzy metody z parametrami domyślnymi: $\mathrm{tol} = 10^{-5}$, $\alpha = 0.1$ z warunkiem Armijo, $\Delta = 0.5$, z ograniczeniami. Błąd liczony jest względem minimum globalnego na $[a,b]$.
if ~exist('F', 'var'), F = funkcje_testowe(); end
par = domyslne_parametry();
metody  = {'zloty', 'gradient', 'powell'};
wiersze = cell(0, 8);
figure('Name', 'Porównanie zbieżności', 'Color', 'w', 'Position', [100 100 1150 800]);
t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for i = 1:numel(F)
    [xr, fr] = minimum_ref(F(i));
    Ws = cell(1, 3);
    for j = 1:3
        W = uruchom_metode(metody{j}, F(i), par);   Ws{j} = W;
        wiersze(end+1, :) = {F(i).nazwa, W.metoda, W.xopt, W.fopt, ...
                             abs(W.xopt - xr), W.iter, W.nf, W.stop}; %#ok<SAGROW>
    end
    ax = nexttile(t);
    rysuj_zbieznosc(ax, Ws, xr);
    title(ax, {F(i).nazwa, sprintf('x_{ref} = %.6f', xr)});
end
T = cell2table(wiersze, 'VariableNames', ...
    {'Funkcja', 'Metoda', 'x_opt', 'f_opt', 'Blad_x', 'Iteracje', 'Obliczenia_f', 'Kryterium_stopu'})
% *Z ograniczeniami czy bez?* Dla f3 z ograniczeniem $x\in[0,3]$ obie metody zatrzymują się na brzegu $x = 3$. Bez ograniczenia schodzą do minimum lokalnego $x \approx 3.026$, które jest niedopuszczalne.
Fi   = F(3);
parZ = domyslne_parametry();               % z ograniczeniami
parB = parZ;   parB.ograniczenia = false;  % bez ograniczeń
figure('Name', 'Ograniczenia – f3', 'Color', 'w', 'Position', [100 100 1150 800]);
t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t, ['f_3(x) = ' Fi.wzor ':   wpływ ograniczenia x \in [0, 3]']);
for m = {'gradient', 'powell'}
    WZ = uruchom_metode(m{1}, Fi, parZ);
    WB = uruchom_metode(m{1}, Fi, parB);
    rysuj_metode(nexttile(t), Fi, WZ, WZ.iter, parZ, 'Z OGRANICZENIEM  x \in [0, 3]');
    rysuj_metode(nexttile(t), Fi, WB, WB.iter, parB, 'BEZ OGRANICZENIA');
end

%% 6. Interaktywny eksplorator
% Osobne okno z pełną kontrolą: wybór funkcji (albo własnej, np. `sin(3*x) + 0.1*x.^2`), metody (albo wszystkich trzech naraz), przedziału, punktu startowego i parametrów. Suwak przewija iteracje, a przycisk *▶ Animuj* odtwarza przebieg algorytmu krok po kroku (ponowne kliknięcie zatrzymuje animację).
% (przycisk w wersji .mlx)
if ~exist('F', 'var'), F = funkcje_testowe(); end
eksplorator(F, domyslne_parametry());

%% 7. Wnioski (parametry domyślne)
% • *Złoty podział* jest najbardziej niezawodny: zbiega na wszystkich funkcjach, także na nieróżniczkowalnej f4 i z minimum na brzegu (f3), liniowo z ilorazem $\tau\approx0.618$ – 27–28 iteracji i 29–30 obliczeń $f$ dla $\mathrm{tol}=10^{-5}$. Wymaga jednak unimodalności na $[a,b]$: dla f2 trafił w minimum globalne tylko dzięki symetrycznemu przedziałowi $[-2.5,\,2.5]$; na $[-1,\,2.5]$ zbiega do minimum lokalnego $x\approx1.347$.
% • *Metoda gradientu* jest najdroższa (pochodna numeryczna: 34–145 obliczeń $f$) i lokalna: dla f2 z $x_0 = 0.5$ trafia w minimum lokalne $x\approx1.347$, z $x_0=-0.5$ – w globalne. Dla f1 zatrzymała się z błędem $3\cdot10^{-5} > \mathrm{tol}$ – przy zbieżności liniowej warunek $|x_{k+1}-x_k|<\mathrm{tol}$ nie gwarantuje błędu mniejszego niż tol. Ze stałym krokiem jest wrażliwa na $\alpha$: f2 przy $\alpha=0.3$ nie zbiega, f4 przy $\alpha=0.1$ oscyluje wokół załamania (200 iteracji bez spełnienia kryterium); z warunkiem Armijo oba przypadki zbiegają.
% • *Metoda Powella* jest najszybsza dla funkcji gładkich: f1 w 5 iteracjach (7 obliczeń $f$), f3 w 2 iteracjach (wierzchołek rzutowany na brzeg). Na f4 potrzebowała 23 iteracji i dała największy błąd ($2.8\cdot10^{-5}$), bo parabola źle przybliża załamanie. Jest metodą lokalną (f2 → $x\approx1.347$).
% • *Ograniczenia:* rzut na $[a,b]$ w gradiencie i metodzie Powella poprawnie wyznacza minimum na brzegu (f3: $x^*=3$). Bez ograniczeń obie metody kończą w niedopuszczalnym punkcie $x\approx3.026$.
