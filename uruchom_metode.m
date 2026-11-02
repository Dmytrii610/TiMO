function W = uruchom_metode(metoda, Fi, par)
% URUCHOM_METODE  Wywołuje wybraną metodę dla funkcji Fi z parametrami par.
%   metoda: 'zloty' | 'gradient' | 'powell'
if par.ograniczenia
    lb = Fi.a;  ub = Fi.b;
else
    lb = -Inf;  ub = Inf;
end
switch lower(metoda)
    case 'zloty'          % złoty podział zawsze pracuje na przedziale [a,b]
        W = zloty_podzial(Fi.f, Fi.a, Fi.b, par.tol, par.maxIter);
    case 'gradient'
        W = metoda_gradientu(Fi.f, Fi.x0, par.alfa, par.tol, par.maxIter, lb, ub, par.armijo);
    case 'powell'
        W = powell_kwadr(Fi.f, Fi.x0, par.delta, par.tol, par.maxIter, lb, ub);
    otherwise
        error('Nieznana metoda: %s', metoda);
end
W.klucz = lower(metoda);
end
