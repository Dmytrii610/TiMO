function W = zloty_podzial(f, a, b, tol, maxIter)
% ZLOTY_PODZIAL  Minimalizacja funkcji jednej zmiennej metodą złotego podziału.
%   W = zloty_podzial(f, a, b, tol, maxIter)
%   f       – uchwyt do funkcji celu f(x)
%   [a,b]   – przedział poszukiwań (jednocześnie ograniczenie x ∈ [a,b])
%   tol     – wymagana długość końcowego przedziału
%   maxIter – maksymalna liczba iteracji
%   W       – struktura z wynikiem i pełną historią iteracji
tau = (sqrt(5) - 1)/2;                 % 0.618... – współczynnik złotego podziału
x1 = b - tau*(b - a);   f1 = f(x1);
x2 = a + tau*(b - a);   f2 = f(x2);
nf = 2;

H = [a b x1 x2 f1 f2];                 % historia: [a b x1 x2 f(x1) f(x2)]
k = 0;
while (b - a) > tol && k < maxIter
    k = k + 1;
    if f1 > f2                         % minimum leży w [x1, b]
        a  = x1;
        x1 = x2;  f1 = f2;
        x2 = a + tau*(b - a);  f2 = f(x2);
    else                               % minimum leży w [a, x2]
        b  = x2;
        x2 = x1;  f2 = f1;
        x1 = b - tau*(b - a);  f1 = f(x1);
    end
    nf = nf + 1;                       % tylko JEDNO nowe obliczenie f na iterację
    H(end+1, :) = [a b x1 x2 f1 f2]; %#ok<AGROW>
end

% przybliżenie minimum w każdej iteracji = lepszy z dwóch punktów wewnętrznych
lepszy = H(:,5) <= H(:,6);
xk = H(:,4);  xk(lepszy) = H(lepszy,3);
fk = H(:,6);  fk(lepszy) = H(lepszy,5);

W.metoda = 'Złoty podział';
W.hist   = H;
W.xk     = xk;
W.fk     = fk;
W.xopt   = xk(end);
W.fopt   = fk(end);
W.iter   = k;
W.nf     = nf;
if (b - a) <= tol
    W.stop = sprintf('długość przedziału %.2e <= tol', b - a);
else
    W.stop = 'osiągnięto maxIter';
end
end
