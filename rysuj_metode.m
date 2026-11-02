function rysuj_metode(ax, Fi, W, k, par, dopisek)
% RYSUJ_METODE  Rysuje stan metody W po k iteracjach na osiach ax.
%   k = 0 – stan początkowy, k = W.iter – stan końcowy.
%   dopisek – (opcjonalnie) dodatkowa linia tytułu
k  = max(0, min(round(k), W.iter));
xl = zakres_x(Fi, W);
cla(ax);  hold(ax, 'on');  grid(ax, 'on');  box(ax, 'on');
xx = linspace(xl(1), xl(2), 600);
yy = wartosci(Fi.f, xx);
hf = plot(ax, xx, yy, 'k-', 'LineWidth', 1.4);
yl = [min(yy) max(yy)];  dy = max(diff(yl), 1e-9);
% ograniczenia x ∈ [a,b] (dla złotego podziału – zawsze)
if par.ograniczenia || strcmp(W.klucz, 'zloty')
    cb = [0.45 0.45 0.45];             % ograniczenia aktywne w algorytmie
else
    cb = [0.82 0.82 0.82];             % bez ograniczeń – [a,b] tylko informacyjnie
end
pion(ax, Fi.a, yl, cb);
pion(ax, Fi.b, yl, cb);
switch W.klucz
    case 'zloty',    [h, lab, tyt] = rys_zloty(ax, Fi, W, k, yl, dy);
    case 'gradient', [h, lab, tyt] = rys_gradient(ax, Fi, W, k, xl, dy);
    case 'powell',   [h, lab, tyt] = rys_powell(ax, Fi, W, k, xl, yl, dy);
end
hold(ax, 'off');
xlim(ax, xl);
yy0 = get(ax, 'YLim');
ylim(ax, [min(yy0(1), yl(1) - 0.05*dy), yl(2) + 0.08*dy]);
xlabel(ax, 'x');  ylabel(ax, 'f(x)');
if nargin > 5 && ~isempty(dopisek), tyt = [tyt {dopisek}]; end
title(ax, tyt);
legend(ax, [hf h], [{['f(x) = ' Fi.wzor]} lab], 'Location', 'best');
end

% ======================================================================
function [h, lab, tyt] = rys_zloty(ax, ~, W, k, yl, dy)
H  = W.hist;   n = size(H, 1) - 1;
% pasek każdego przedziału [a_i, b_i] pod wykresem funkcji
pas = 0.30*dy/max(n, 1);
for i = 0:k
    y = yl(1) - 0.06*dy - i*pas;
    plot(ax, H(i+1, 1:2), [y y], '-', 'Color', kolor(i, n), 'LineWidth', 2.5);
end
ak = H(k+1, 1);  bk = H(k+1, 2);
yb = yl(1) - 0.06*dy - k*pas;
patch('XData', [ak bk bk ak], 'YData', [yb yb yl(2) yl(2)], 'Parent', ax, ...
      'FaceColor', [1 0.85 0.3], 'FaceAlpha', 0.25, 'EdgeColor', 'none');
x1 = H(k+1, 3);  x2 = H(k+1, 4);
plot(ax, [x1 x1], [yb H(k+1, 5)], ':', 'Color', [0 0.45 0.74]);
plot(ax, [x2 x2], [yb H(k+1, 6)], ':', 'Color', [0.85 0.33 0.1]);
h1 = plot(ax, x1, H(k+1, 5), 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0 0.45 0.74], 'MarkerEdgeColor', 'k');
h2 = plot(ax, x2, H(k+1, 6), 's', 'MarkerSize', 8, 'MarkerFaceColor', [0.85 0.33 0.1], 'MarkerEdgeColor', 'k');
h3 = plot(ax, W.xk(k+1), W.fk(k+1), 'p', 'MarkerSize', 14, 'MarkerFaceColor', [0.2 0.75 0.2], 'MarkerEdgeColor', 'k');
h = [h1 h2 h3];
lab = {'x_1 = b - \tau(b-a)', 'x_2 = a + \tau(b-a)', 'najlepszy punkt'};
tyt = {sprintf('Złoty podział – iteracja %d/%d', k, W.iter), ...
       sprintf('[a_k, b_k] = [%.5f, %.5f],   b_k - a_k = %.2e', ak, bk, bk - ak)};
end

% ======================================================================
function [h, lab, tyt] = rys_gradient(ax, ~, W, k, xl, ~)
n  = W.iter;
xs = W.xk(1:k+1);  fs = W.fk(1:k+1);
plot(ax, xs, fs, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1);
for i = 0:k
    plot(ax, xs(i+1), fs(i+1), 'o', 'MarkerSize', 6, 'MarkerFaceColor', kolor(i, n), ...
         'MarkerEdgeColor', 'none');
end
h1 = plot(ax, xs(1), fs(1), 's', 'MarkerSize', 10, 'MarkerFaceColor', [0.2 0.75 0.2], 'MarkerEdgeColor', 'k');
h2 = plot(ax, xs(end), fs(end), 'o', 'MarkerSize', 11, 'MarkerFaceColor', [0.9 0.1 0.1], 'MarkerEdgeColor', 'k');
h = [h1 h2];  lab = {'x_0 (start)', 'x_k (bieżący)'};
% styczna w bieżącym punkcie: nachylenie = f'(x_k)
if k+1 <= numel(W.gk)
    g = W.gk(k+1);
    L = 0.08*diff(xl);
    h3 = plot(ax, xs(end) + [-L L], fs(end) + g*[-L L], '-', 'Color', [0.9 0.1 0.1], 'LineWidth', 2);
    h = [h h3];  lab{end+1} = sprintf('styczna, f''(x_k) = %.3g', g);
    tg = sprintf(',  f''(x_k) = %.2e', g);
else
    tg = '';
end
tyt = {sprintf('Gradient – iteracja %d/%d', k, n), sprintf('x_k = %.6f%s', xs(end), tg)};
end

% ======================================================================
function [h, lab, tyt] = rys_powell(ax, ~, W, k, xl, yl, dy)
n = W.iter;   H = W.hist;
h = [];  lab = {};
if k == 0
    X = H(1).X;  F = H(1).F;
    h = plot(ax, X, F, 'o', 'MarkerSize', 9, 'MarkerFaceColor', [0 0.45 0.74], 'MarkerEdgeColor', 'k');
    lab = {'punkty startowe'};
    tyt = {sprintf('Powell – iteracja 0/%d (punkty startowe)', n), ...
           sprintf('x_1 = x_0,  x_2 = x_1 + \\Delta,  x_3   (\\Delta = %g)', abs(X(2) - X(1)))};
    return
end
xx = linspace(xl(1), xl(2), 400);
for i = 1:k                                   % wcześniejsze parabole – blado
    q = parabola(H(i), xx);
    q(q > yl(2) + 0.5*dy | q < yl(1) - 0.5*dy) = NaN;
    if i < k
        plot(ax, xx, q, '-', 'Color', 1 - 0.35*(1 - kolor(i, n)), 'LineWidth', 0.8);
    else
        hq = plot(ax, xx, q, '-', 'Color', [0.93 0.55 0.1], 'LineWidth', 2.2);
    end
end
Hk = H(k);
h1 = plot(ax, Hk.X, Hk.F, 'o', 'MarkerSize', 9, 'MarkerFaceColor', [0 0.45 0.74], 'MarkerEdgeColor', 'k');
pion(ax, Hk.xn, yl, [0.93 0.55 0.1]);
h2 = plot(ax, Hk.xn, Hk.fn, 'p', 'MarkerSize', 15, 'MarkerFaceColor', [0.2 0.75 0.2], 'MarkerEdgeColor', 'k');
h = [hq h1 h2];
lab = {'parabola q(x) w iteracji k', 'punkty x_1, x_2, x_3', 'nowy punkt x^*'};
if Hk.c2 > 0
    opis = sprintf('x^* = %.6f', Hk.xn);
else
    opis = 'parabola wklęsła → krok w dół funkcji';
end
tyt = {sprintf('Powell – iteracja %d/%d', k, n), opis};
end

% ======================================================================
function q = parabola(Hi, x)
X = Hi.X;
q = Hi.F(1) + Hi.c1*(x - X(1)) + Hi.c2*(x - X(1)).*(x - X(2));
end

function pion(ax, x, yl, c)
if isfinite(x)
    plot(ax, [x x], yl + [-0.05 0.05]*diff(yl), '--', 'Color', c, 'LineWidth', 1);
end
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

function c = kolor(i, n)
t = min(max(i/max(n, 1), 0), 1);
c = (1 - t)*[0.62 0.80 1.00] + t*[0.05 0.15 0.50];
end
