function W = pokaz_metode(Fi, metoda, k, par)
% POKAZ_METODE  Uruchamia metodę i rysuje: stan po k iteracjach, stan końcowy
% oraz wykres zbieżności. Wypisuje podsumowanie w oknie poleceń.
W = uruchom_metode(metoda, Fi, par);
[xr, fr] = minimum_ref(Fi);
k = max(0, min(round(k), W.iter));
fig = figure('Name', [W.metoda ' – ' Fi.nazwa], 'Color', 'w', 'Position', [100 100 1150 800]);
t = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t, sprintf('%s:   %s,   f(x) = %s', W.metoda, Fi.nazwa, Fi.wzor));
rysuj_metode(nexttile(t), Fi, W, k, par, '(stan po k iteracjach – suwak k)');
rysuj_metode(nexttile(t), Fi, W, W.iter, par, '(stan końcowy)');
rysuj_zbieznosc(nexttile(t, [1 2]), {W}, xr, k);
fprintf('%s – %s\n', W.metoda, Fi.nazwa);
fprintf('   x*      = %.8f      f(x*) = %.8f\n', W.xopt, W.fopt);
fprintf('   x_ref   = %.8f      f_ref = %.8f   (minimum globalne na [a,b])\n', xr, fr);
fprintf('   |x*-x_ref| = %.2e,  iteracje = %d,  obliczenia f = %d\n', abs(W.xopt - xr), W.iter, W.nf);
fprintf('   kryterium stopu: %s\n', W.stop);
end
