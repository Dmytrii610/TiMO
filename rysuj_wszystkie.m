function rysuj_wszystkie(ax, Fi, Ws, k, ~)
% RYSUJ_WSZYSTKIE  Ścieżki przybliżeń x_k wszystkich metod na jednym wykresie.
xl = [Inf -Inf];
for j = 1:numel(Ws)
    r = zakres_x(Fi, Ws{j});  xl = [min(xl(1), r(1)) max(xl(2), r(2))];
end
cla(ax);  hold(ax, 'on');  grid(ax, 'on');  box(ax, 'on');
xx = linspace(xl(1), xl(2), 600);  yy = wartosci(Fi.f, xx);
h = plot(ax, xx, yy, 'k-', 'LineWidth', 1.4);
lab = {['f(x) = ' Fi.wzor]};
yl = [min(yy) max(yy)];
for x = [Fi.a Fi.b]
    plot(ax, [x x], yl, '--', 'Color', [0.45 0.45 0.45]);
end
for j = 1:numel(Ws)
    W  = Ws{j};  c = kolor_metody(W.klucz);
    kk = max(0, min(round(k), W.iter));
    xs = W.xk(1:kk+1);  fs = W.fk(1:kk+1);
    plot(ax, xs, fs, '.-', 'Color', 1 - 0.5*(1 - c), 'MarkerSize', 10);
    h(end+1) = plot(ax, xs(end), fs(end), 'o', 'MarkerSize', 11, 'LineWidth', 2, ...
                    'MarkerFaceColor', c, 'MarkerEdgeColor', 'k'); %#ok<AGROW>
    lab{end+1} = sprintf('%s: x_k = %.5f', W.metoda, xs(end)); %#ok<AGROW>
end
hold(ax, 'off');  xlim(ax, xl);
xlabel(ax, 'x');  ylabel(ax, 'f(x)');
title(ax, sprintf('Wszystkie metody – iteracja k = %d', round(k)));
legend(ax, h, lab, 'Location', 'best');
end

function xl = zakres_x(Fi, W)
x = [Fi.a Fi.b W.xk(:)'];
if isfield(W, 'hist') && isstruct(W.hist) && ~isempty(W.hist)
    x = [x [W.hist.X] [W.hist.xn]];
end
x = x(isfinite(x));
lo = min(x);  hi = max(x);
d  = max(hi - lo, 1e-6);
xl = [lo - 0.06*d, hi + 0.06*d];
end

function c = kolor_metody(klucz)
switch klucz
    case 'zloty',    c = [0.85 0.60 0.00];
    case 'gradient', c = [0.85 0.15 0.15];
    otherwise,       c = [0.10 0.45 0.80];
end
end
