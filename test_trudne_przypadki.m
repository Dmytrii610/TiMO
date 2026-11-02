%% Teoria i Metody Optymalizacji – Część A: Testy przypadków trudnych i awaryjnych
% Skrypt korzysta bezpośrednio z wyodrębnionych funkcji projektu:
%   - uruchom_metode.m  (wywołującej zloty_podzial.m, metoda_gradientu.m, powell_kwadr.m)
%   - domyslne_parametry.m, minimum_ref.m
%   - rysuj_metode.m, rysuj_zbieznosc.m, rysuj_wszystkie.m
%
% Wyniki (wykresy PNG oraz tabela CSV) są automatycznie zapisywane
% do osobnego folderu: ./wykresy_trudne_przypadki/

clear; close all; clc;

%% 1. Konfiguracja folderu wyjściowego
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir)
    scriptDir = pwd;
end
addpath(scriptDir);

outDir = fullfile(scriptDir, 'wykresy_trudne_przypadki');
if ~exist(outDir, 'dir')
    mkdir(outDir);
    fprintf('Utworzono folder wyjściowy: %s\n', outDir);
else
    fprintf('Folder wyjściowy: %s\n', outDir);
end

%% 2. Definicja przypadków testowych
P = definicje_przypadkow();
metody = {'zloty', 'gradient', 'powell'};
wiersze = cell(0, 10);

%% 3. Uruchomienie testów i generowanie wykresów dla każdego przypadku
for i = 1:numel(P)
    Pi  = P(i);
    par = Pi.par;
    [xr, fr] = minimum_ref(Pi);

    Ws = cell(1, 3);
    czySukces = false(1, 3);
    for j = 1:3
        W = uruchom_metode(metody{j}, Pi, par);
        Ws{j} = W;
        blad_x = abs(W.xopt - xr);
        blad_f = abs(W.fopt - fr);
        czySukces(j) = (blad_x < 1e-3);

        if czySukces(j)
            statusTxt = 'SUKCES';
        else
            statusTxt = 'PORAŻKA';
        end

        wiersze(end+1, :) = {Pi.id, Pi.kto_zawodzi, Pi.wzor, W.metoda, ...
                             W.xopt, xr, blad_x, blad_f, W.iter, statusTxt}; %#ok<SAGROW>
    end

    % --- Rysowanie szczegółowej planszy 2x2 z użyciem rysuj_metode i rysuj_zbieznosc ---
    fig = figure('Name', Pi.nazwa, 'Color', 'w', 'Visible', 'off', ...
                 'Position', [80 80 1280 820]);
    t = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, {sprintf('%s (%s):  f(x) = %s', Pi.nazwa, Pi.kto_zawodzi, Pi.wzor), ...
              sprintf('Przedział [a, b] = [%.2g, %.2g],   start x_0 = %.2g,   x_{ref} = %.4f (f_{ref} = %.4f)', ...
              Pi.a, Pi.b, Pi.x0, xr, fr)}, 'FontWeight', 'bold', 'FontSize', 12);

    for j = 1:3
        ax = nexttile(t);
        if czySukces(j)
            dopisek = sprintf('[SUKCES]  błąd |x^* - x_{ref}| = %.2e (%s)', abs(Ws{j}.xopt - xr), Ws{j}.stop);
        else
            dopisek = sprintf('[PORAŻKA]  błąd |x^* - x_{ref}| = %.2e (%s)', abs(Ws{j}.xopt - xr), Ws{j}.stop);
        end
        rysuj_metode(ax, Pi, Ws{j}, Ws{j}.iter, par, dopisek);
    end

    axZb = nexttile(t);
    rysuj_zbieznosc(axZb, Ws, xr);

    outPath = fullfile(outDir, sprintf('%s.png', Pi.plik));
    zapisz_wykres(fig, outPath);
    close(fig);
    fprintf('[%d/%d] Zapisano wykres: %s\n', i, numel(P), outPath);
end

%% 4. Zbiorczy wykres porównawczy wszystkich 6 przypadków (z użyciem rysuj_wszystkie)
figAll = figure('Name', 'Podsumowanie trudnych przypadków', 'Color', 'w', ...
                'Visible', 'off', 'Position', [60 60 1400 900]);
tAll = tiledlayout(figAll, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tAll, 'Porównanie przebiegu wszystkich metod na trudnych przypadkach', ...
      'FontWeight', 'bold', 'FontSize', 13);

for i = 1:numel(P)
    Pi = P(i);
    Ws = cellfun(@(m) uruchom_metode(m, Pi, Pi.par), metody, 'UniformOutput', false);
    kmax = max(cellfun(@(W) W.iter, Ws));
    ax = nexttile(tAll);
    rysuj_wszystkie(ax, Pi, Ws, kmax, Pi.par);
    title(ax, {sprintf('%s: f(x) = %s', Pi.id, Pi.wzor), Pi.kto_zawodzi});
end

outSummaryPlot = fullfile(outDir, '00_podsumowanie_wszystkich.png');
zapisz_wykres(figAll, outSummaryPlot);
close(figAll);
fprintf('Zapisano wykres zbiorczy: %s\n\n', outSummaryPlot);

%% 5. Tabela podsumowująca w konsoli i zapis do CSV
T = cell2table(wiersze, 'VariableNames', ...
    {'Przypadek', 'Cel_testu', 'Funkcja', 'Metoda', 'x_opt', 'x_ref', ...
     'Blad_x', 'Blad_f', 'Iteracje', 'Status'});
disp(T);

csvPath = fullfile(outDir, 'podsumowanie_wynikow.csv');
writetable(T, csvPath);
fprintf('Zapisano tabelę wyników: %s\n', csvPath);


%% ========================================================================
%  DEFINICJE PRZYPADKÓW TESTOWYCH
%  ========================================================================
function P = definicje_przypadkow()
parDom = domyslne_parametry();

P = struct('id', {}, 'plik', {}, 'nazwa', {}, 'kto_zawodzi', {}, ...
           'wzor', {}, 'f', {}, 'a', {}, 'b', {}, 'x0', {}, ...
           'par', {}, 'opis', {}, 'xplot', {});

% --- Przypadek 1: Złoty podział zawodzi (niesymetryczny przedział na funkcji multimodalnej) ---
P(1).id          = 'P1';
P(1).plik        = '01_porazka_zloty_podzial_multimodalna';
P(1).nazwa       = 'P1: Multimodalna (niesymetryczny przedział)';
P(1).kto_zawodzi = 'zawodzi: Złoty podział';
P(1).wzor        = 'x^4 - 4x^2 + x';
P(1).f           = @(x) x.^4 - 4*x.^2 + x;
P(1).a           = -1.8;
P(1).b           = 2.5;
P(1).x0          = -1.0;
P(1).par         = parDom;
P(1).opis        = 'W 1. kroku f(x1) > f(x2), więc złoty podział odrzuca lewą część przedziału z minimum globalnym.';
P(1).xplot       = [-2.0 2.6];

% --- Przypadek 2: Złoty podział zawodzi (wąska głęboka studnia potencjału) ---
P(2).id          = 'P2';
P(2).plik        = '02_porazka_zloty_podzial_waska_studnia';
P(2).nazwa       = 'P2: Wąska głęboka studnia';
P(2).kto_zawodzi = 'zawodzi: Złoty podział i Powell';
P(2).wzor        = '(x - 1)^2 - 5 exp(-50(x + 1)^2)';
P(2).f           = @(x) (x - 1).^2 - 5*exp(-50*(x + 1).^2);
P(2).a           = -2.0;
P(2).b           = 2.0;
P(2).x0          = -0.8;
P(2).par         = parDom;
P(2).opis        = 'Punkty próbkowania złotego podziału omijają wąską studnię wokół x = -1 i zbiegają do x = 1.';
P(2).xplot       = [-2.2 2.2];

% --- Przypadek 3: Gradient zawodzi (punkt przegięcia / stacjonarny f'(x0) = 0) ---
P(3).id          = 'P3';
P(3).plik        = '03_porazka_gradient_punkt_przegiecia';
P(3).nazwa       = 'P3: Punkt przegięcia na starcie';
P(3).kto_zawodzi = 'zawodzi: Gradient (f''(x_0) = 0)';
P(3).wzor        = '(x + 1)^3 (x - 2)';
P(3).f           = @(x) (x + 1).^3 .* (x - 2);
P(3).a           = -2.0;
P(3).b           = 3.0;
P(3).x0          = -1.0;
P(3).par         = parDom;
P(3).opis        = 'W punkcie przegięcia x0 = -1 pochodna wynosi 0 – gradient zatrzymuje się w 0. iteracji.';
P(3).xplot       = [-2.2 3.2];

% --- Przypadek 4: Gradient zawodzi (płaskie plateau / zanikający gradient) ---
P(4).id          = 'P4';
P(4).plik        = '04_porazka_gradient_plaskie_plateau';
P(4).nazwa       = 'P4: Płaskie plateau (zanik pochodnej)';
P(4).kto_zawodzi = 'zawodzi: Gradient (zanik pochodnej)';
P(4).wzor        = '-exp(-(x - 1)^2)';
P(4).f           = @(x) -exp(-(x - 1).^2);
P(4).a           = -3.0;
P(4).b           = 3.0;
P(4).x0          = -2.5;
P(4).par         = parDom;
P(4).opis        = 'Daleko od minimum pochodna jest rzędu 1e-5, więc krok |x_{k+1}-x_k| < tol kończy algorytm.';
P(4).xplot       = [-3.2 3.2];

% --- Przypadek 5: Gradient zawodzi (funkcja nieróżniczkowalna ze stałym krokiem) ---
parBezArmijo        = parDom;
parBezArmijo.armijo = false;
P(5).id          = 'P5';
P(5).plik        = '05_porazka_gradient_nierozniczkowalna';
P(5).nazwa       = 'P5: Funkcja nieróżniczkowalna (bez Armijo)';
P(5).kto_zawodzi = 'zawodzi: Gradient bez Armijo';
P(5).wzor        = '|x - 1|';
P(5).f           = @(x) abs(x - 1);
P(5).a           = -2.0;
P(5).b           = 3.0;
P(5).x0          = 0.25;
P(5).par         = parBezArmijo;
P(5).opis        = 'Pochodna skacze między -1 a +1; ze stałym krokiem alfa = 0.1 metoda oscyluje aż do maxIter.';
P(5).xplot       = [-2.2 3.2];

% --- Przypadek 6: Powell zawodzi (silna asymetria, przestrzelenie paraboli) ---
P(6).id          = 'P6';
P(6).plik        = '06_porazka_powell_silna_asymetria';
P(6).nazwa       = 'P6: Silna asymetria (przestrzelenie paraboli)';
P(6).kto_zawodzi = 'zawodzi: Powell (fałszywy stop)';
P(6).wzor        = 'e^{5x} - 5x';
P(6).f           = @(x) exp(5*x) - 5*x;
P(6).a           = -3.0;
P(6).b           = 3.0;
P(6).x0          = -2.0;
P(6).par         = parDom;
P(6).opis        = 'Dla x < -1 funkcja jest niemal liniowa; wierzchołek paraboli ląduje na brzegu b=3 i blokuje metodę w x=-1.';
P(6).xplot       = [-3.2 3.2];
end

function zapisz_wykres(fig, sciezka)
try
    exportgraphics(fig, sciezka, 'Resolution', 150);
catch
    saveas(fig, sciezka);
end
end
