function W = powell_kwadr(f, x0, delta, tol, maxIter, lb, ub)
% POWELL_KWADR  Metoda aproksymacji kwadratowej Powella (funkcja 1D).
%   W = powell_kwadr(f, x0, delta, tol, maxIter, lb, ub)
%   x0     – punkt startowy,  delta – krok do wyznaczenia punktów startowych
%   lb, ub – ograniczenia ([-Inf, Inf] = brak ograniczeń); punkt
%            wyznaczony z paraboli jest rzutowany na [lb, ub]
% W każdej iteracji przez 3 punkty prowadzona jest parabola
%   q(x) = f1 + c1(x - x1) + c2(x - x1)(x - x2),
% a jej wierzchołek  x* = (x1 + x2)/2 - c1/(2 c2)  staje się nowym punktem.
% Spośród 4 punktów odrzucany jest ten o największej wartości f.
P = @(x) min(max(x, lb), ub);

% --- trzy punkty startowe (jak w klasycznym algorytmie Powella) ---
x1 = P(x0);           f1 = f(x1);
x2 = P(x1 + delta);
if x2 == x1, x2 = P(x1 - delta); end
f2 = f(x2);
if f2 <= f1, x3 = P(x1 + 2*(x2 - x1)); else, x3 = P(x1 - (x2 - x1)); end
if any(abs(x3 - [x1 x2]) < eps(max(1, abs(x3))))      % kolizja na ograniczeniu
    x3 = (x1 + x2)/2;
end
f3 = f(x3);   nf = 3;
X = [x1 x2 x3];   F = [f1 f2 f3];

H = struct('X', {}, 'F', {}, 'c1', {}, 'c2', {}, 'xn', {}, 'fn', {});
[F0, i0] = min(F);
xk = X(i0);   fk = F0;
stop = 'osiągnięto maxIter';
k = 0;
while k < maxIter
    k = k + 1;
    [X, s] = sort(X);  F = F(s);
    c1 = (F(2) - F(1))/(X(2) - X(1));
    c2 = ((F(3) - F(1))/(X(3) - X(1)) - c1)/(X(3) - X(2));
    [fb, ib] = min(F);   xb = X(ib);
    if c2 > 0                                      % parabola wypukła – wierzchołek
        xn = (X(1) + X(2))/2 - c1/(2*c2);
    else                                           % parabola wklęsła/prosta –
        L = X(3) - X(1);                           % krok w stronę mniejszych f
        if F(1) <= F(3), xn = X(1) - 2*L; else, xn = X(3) + 2*L; end
    end
    xn = P(xn);
    if abs(xn - xb) < tol                          % warunek stopu
        H(end+1) = struct('X', X, 'F', F, 'c1', c1, 'c2', c2, 'xn', xn, 'fn', fb); %#ok<AGROW>
        xk(end+1) = xb;  fk(end+1) = fb; %#ok<AGROW>
        stop = sprintf('|x* - x_best| = %.2e < tol', abs(xn - xb));
        break
    end
    fn = f(xn);   nf = nf + 1;
    H(end+1) = struct('X', X, 'F', F, 'c1', c1, 'c2', c2, 'xn', xn, 'fn', fn); %#ok<AGROW>
    % zamiana punktów: z 4 punktów (posortowanych) zostaje najlepszy i jego
    % dwaj sąsiedzi – dzięki temu zachowane jest „otoczenie” minimum
    % (przedział zawierający minimum nie może się powiększyć)
    [X4, s] = sort([X xn]);  F4 = [F fn];  F4 = F4(s);
    [~, ib] = min(F4);
    ib = min(max(ib, 2), 3);
    Xn = X4(ib-1:ib+1);   Fn = F4(ib-1:ib+1);
    if isequal(Xn, X) || numel(unique(Xn)) < 3
        X = Xn;  F = Fn;
        [fb, ib] = min(F);
        xk(end+1) = X(ib);  fk(end+1) = fb; %#ok<AGROW>
        stop = 'brak postępu – zbiór punktów się nie zmienia';
        break
    end
    X = Xn;  F = Fn;
    [fb, ib] = min(F);
    xk(end+1) = X(ib);  fk(end+1) = fb; %#ok<AGROW>
end

W.metoda = 'Powell';
W.hist = H;
W.xk   = xk(:);
W.fk   = fk(:);
W.xopt = xk(end);
W.fopt = fk(end);
W.iter = k;
W.nf   = nf;
W.stop = stop;
W.lb = lb;  W.ub = ub;
end
