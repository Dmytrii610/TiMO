function par = domyslne_parametry()
% DOMYSLNE_PARAMETRY  Wspólne, domyślne parametry wszystkich metod.
par.tol          = 1e-5;   % tolerancja: długość przedziału / krok / |f'(x)|
par.maxIter      = 200;    % maksymalna liczba iteracji
par.alfa         = 0.1;    % krok metody gradientu (przy Armijo – krok początkowy)
par.armijo       = true;   % true – krok Armijo (backtracking), false – krok stały
par.delta        = 0.5;    % krok startowy metody Powella
par.ograniczenia = true;   % gradient/Powell: true – x ∈ [a,b], false – bez ograniczeń
end
