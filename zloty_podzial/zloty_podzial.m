function [xmin, fmin, iter, epsilon] = zloty_podzial(f, a, b, maxIter, tol)
%   Parametry:
%     f       – wskaźnik do funkcji celu
%     a, b    – przedział  [a, b]
%     maxIter – maksymalna liczba iteracji
%     tol     – dokładność: domyślnie 0
%
%   Output:
%     xmin    – przybliżenie punktu minimum
%     fmin    – wartość funkcji w xmin
%     iter    – liczba wykonanych iteracji
%     epsilon – połowa długości końcowego przedziału, (b_k - a_k)/2.
%               Dla funkcji unimodalnej minimum leży w [a_k, b_k], więc
%               |xmin - x*| <= epsilon.

if nargin < 5 || isempty(tol)
    tol = 0;
end
if a >= b
    error('zloty_podzial: musi zachodzić a < b.');
end

tau = (sqrt(5) - 1) / 2;

x1 = b - tau*(b - a);   f1 = f(x1);
x2 = a + tau*(b - a);   f2 = f(x2);

iter = 0;
while iter < maxIter && (b - a)/2 > tol
    iter = iter + 1;
    if f1 > f2
        a  = x1;
        x1 = x2;   f1 = f2;
        x2 = a + tau*(b - a);   f2 = f(x2);
    else
        b  = x2;
        x2 = x1;   f2 = f1;
        x1 = b - tau*(b - a);   f1 = f(x1);
    end
end

xmin    = (a + b) / 2;
fmin    = f(xmin);
epsilon = (b - a) / 2;
end
