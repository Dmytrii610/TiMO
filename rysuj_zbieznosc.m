function rysuj_zbieznosc(ax, Ws, xref, k)
% RYSUJ_ZBIEZNOSC  Błąd |x_k - x_ref| w kolejnych iteracjach (skala log).
%   Ws – komórka ze strukturami wyników, k – zaznaczona iteracja (opcjonalnie)
if ~iscell(Ws), Ws = {Ws}; end
if nargin < 4, k = []; end
cla(ax);  hold(ax, 'on');  grid(ax, 'on');  box(ax, 'on');
h = [];  lab = {};
for j = 1:numel(Ws)
    W = Ws{j};
    e = abs(W.xk(:) - xref) + 1e-16;
    it = (0:numel(e)-1)';
    c = kolor_metody(W.klucz);
    h(end+1) = plot(ax, it, e, '.-', 'Color', c, 'LineWidth', 1.4, 'MarkerSize', 12); %#ok<AGROW>
    lab{end+1} = sprintf('%s (%d it., %d obl. f)', W.metoda, W.iter, W.nf); %#ok<AGROW>
    if numel(Ws) == 1 && numel(e) > 2         % dla jednej metody: także zbieżność
        e2 = abs(W.xk(1:end-1) - W.xk(end)) + 1e-16;   % do własnego punktu końcowego
        h(end+1) = plot(ax, it(1:end-1), e2, '--', 'Color', 0.5 + 0.5*c, 'LineWidth', 1.4); %#ok<AGROW>
        lab{1} = [lab{1} ' – względem x_{ref}'];
        lab{end+1} = 'względem punktu końcowego x_K'; %#ok<AGROW>
    end
    if ~isempty(k)
        kk = min(round(k), numel(e) - 1);
        plot(ax, kk, e(kk+1), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', c, 'LineWidth', 2);
    end
end
hold(ax, 'off');
set(ax, 'YScale', 'log');
xlabel(ax, 'iteracja k');
if numel(Ws) == 1, ylabel(ax, 'błąd  |x_k - x|'); else, ylabel(ax, '|x_k - x_{ref}|'); end
title(ax, sprintf('Zbieżność (x_{ref} = %.6f)', xref));
legend(ax, h, lab, 'Location', 'best');
end

function c = kolor_metody(klucz)
switch klucz
    case 'zloty',    c = [0.85 0.60 0.00];
    case 'gradient', c = [0.85 0.15 0.15];
    otherwise,       c = [0.10 0.45 0.80];
end
end
