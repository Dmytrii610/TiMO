function W = metoda_gradientu(f, x0, alfa, tol, maxIter, lb, ub, armijo)
% METODA_GRADIENTU  Metoda najszybszego spadku (gradientu) dla funkcji 1D.
%   W = metoda_gradientu(f, x0, alfa, tol, maxIter, lb, ub, armijo)
%   x0      – punkt startowy
%   alfa    – długość kroku (przy armijo=true: krok początkowy)
%   lb, ub  – ograniczenia; [-Inf, Inf] = zadanie bez ograniczeń.
%             Przy ograniczeniach stosowany jest gradient RZUTOWANY:
%             x(k+1) = P[lb,ub]( x(k) - alfa*f'(x(k)) )
%   armijo  – true: krok dobierany przez backtracking (warunek Armijo),
%             false: stały krok alfa
% Pochodna liczona numerycznie (różnica centralną), więc metoda działa
% dla dowolnej funkcji podanej uchwytem.
P  = @(x) min(max(x, lb), ub);         % rzut na zbiór dopuszczalny
c1 = 1e-4;                             % stała w warunku Armijo

x  = P(x0);   fx = f(x);   nf = 1;
xk = x;  fk = fx;  gk = [];  ak = [];
stop = 'osiągnięto maxIter';
k = 0;
while k < maxIter
    h = 1e-6*max(1, abs(x));
    g = (f(x + h) - f(x - h))/(2*h);   nf = nf + 2;
    gk(end+1) = g; %#ok<AGROW>
    if abs(g) < tol
        stop = sprintf('|f''(x)| = %.2e < tol', abs(g));
        break
    end
    t = alfa;
    xn = P(x - t*g);   fn = f(xn);   nf = nf + 1;
    if armijo                          % backtracking: t <- t/2
        nb = 0;
        while fn > fx + c1*g*(xn - x) && nb < 40
            t = t/2;  nb = nb + 1;
            xn = P(x - t*g);  fn = f(xn);  nf = nf + 1;
        end
    end
    k  = k + 1;
    ak(end+1) = t; %#ok<AGROW>
    dx = abs(xn - x);
    x  = xn;  fx = fn;
    xk(end+1) = x;  fk(end+1) = fx; %#ok<AGROW>
    if ~isfinite(x) || abs(x) > 1e8
        stop = 'rozbieżność (krok za duży)';
        break
    end
    if dx < tol
        if x == lb || x == ub
            stop = sprintf('krok rzutowany < tol – minimum na ograniczeniu x = %g', x);
        else
            stop = sprintf('|x(k+1)-x(k)| = %.2e < tol', dx);
        end
        break
    end
end

W.metoda = 'Gradient';
W.xk   = xk(:);
W.fk   = fk(:);
W.gk   = gk(:);
W.ak   = ak(:);
W.hist = [W.xk W.fk];
W.xopt = x;
W.fopt = fx;
W.iter = k;
W.nf   = nf;
W.stop = stop;
W.lb = lb;  W.ub = ub;
end
