function wyniki = test_zloty_podzial(maxIter, tol)
%   test_zloty_podzial()              – 50 iteracji na test
%   test_zloty_podzial(maxIter, tol)  – własna liczba iteracji i dokładność
%
%   Wydruk:
%     iter    – liczba wykonanych iteracji
%     x_num   – minimum uzyskane numerycznie
%     x_doc   – minimum docelowe (testowe)
%     |dx|    – błąd położenia minimum
%     |df|    – błąd wartości minimum
%     eps     – połowa długości końcowego przedziału

if nargin < 1 || isempty(maxIter), maxIter = 50; end
if nargin < 2 || isempty(tol),     tol = 0;      end


T(1).nazwa = 'UNIMODALNA';
T(1).f = @f_unimodalna;
T(1).stacjonarne = log(2);
T(1).przedzialy = [ -2    3        % minimum wewnątrz, przedział niesymetryczny
                     0    1        % wąski przedział
                   -10   10        % szeroki przedział
                     1    4        % minimum poza przedziałem -> lewy koniec x = 1
                    -3    0 ];     % minimum poza przedziałem -> prawy koniec x = 0

T(2).nazwa = 'MULTIMODALNA';
T(2).f = @f_multimodalna;
r = roots([4 0 -8 1]);
T(2).stacjonarne = sort(real(r(abs(imag(r)) < 1e-12)))';
T(2).przedzialy = [ -2.5  2.5      % oba minima w przedziale
                    -2    0        % tylko minimum globalne
                     0.5  2        % tylko minimum lokalne x ≈ 1.347
                    -1    2.5      % minimum lokalne wewnątrz, globalne na końcu x = -1
                    -2.5  1 ];     % minimum globalne i maksimum lokalne


fprintf('Metoda złotego podziału: maxIter = %d, tol = %g\n', maxIter, tol);
wiersze = {};
for t = 1:numel(T)
    f = T(t).f;
    fprintf('\n%s\n', T(t).nazwa);
    fprintf(['%2s  %-16s %4s  %13s %13s  %13s %13s  %9s %9s %9s\n'], ...
            'nr', 'przedział', 'iter', 'x_num', 'f(x_num)', 'x_doc', 'f(x_doc)', ...
            '|dx|', '|df|', 'eps');
    fprintf('%s\n', repmat('-', 1, 120));
    for i = 1:size(T(t).przedzialy, 1)
        a = T(t).przedzialy(i, 1);
        b = T(t).przedzialy(i, 2);

        [xn, fn, iter, epsilon] = zloty_podzial(f, a, b, maxIter, tol);
        [xd, fd] = minimum_docelowe(f, a, b, T(t).stacjonarne);
        dx = abs(xn - xd);
        df = abs(fn - fd);

        fprintf('%2d  [%6.2f, %6.2f] %4d  %13.9f %13.9f  %13.9f %13.9f  %9.2e %9.2e %9.2e\n', ...
                i, a, b, iter, xn, fn, xd, fd, dx, df, epsilon);
        wiersze(end+1, :) = {T(t).nazwa, a, b, iter, xn, fn, xd, fd, dx, df, epsilon}; %#ok<AGROW>
    end
end
fprintf('\n');

if nargout > 0
    wyniki = cell2table(wiersze, 'VariableNames', {'Funkcja', 'a', 'b', 'iter', ...
        'x_num', 'f_num', 'x_doc', 'f_doc', 'blad_x', 'blad_f', 'epsilon'});
end
end

function [xd, fd] = minimum_docelowe(f, a, b, stacjonarne)
kandydaci = [a, b, stacjonarne(stacjonarne > a & stacjonarne < b)];
[fd, k] = min(f(kandydaci));
xd = kandydaci(k);
end
