function F = funkcje_testowe()
% FUNKCJE_TESTOWE  Zestaw funkcji celu do testowania algorytmów 1D.
%   Każdy element: nazwa, f, przedział [a,b], punkt startowy x0, opis.
F = struct('nazwa', {}, 'wzor', {}, 'f', {}, 'a', {}, 'b', {}, 'x0', {}, 'opis', {}, 'xplot', {});

F(1).nazwa = 'f1: unimodalna';
F(1).wzor  = '(x-2)^2 + 0.5 e^{0.3x}';
F(1).f     = @(x) (x - 2).^2 + 0.5*exp(0.3*x);
F(1).a = -1;  F(1).b = 5;  F(1).x0 = -0.5;
F(1).xplot = [-1.5 5.5];      % zakres osi x na wykresie przeglądowym
F(1).opis  = 'gładka, wypukła, minimum wewnątrz [a,b] (ograniczenia nieaktywne)';

F(2).nazwa = 'f2: multimodalna';
F(2).wzor  = 'x^4 - 4x^2 + x';
F(2).f     = @(x) x.^4 - 4*x.^2 + x;
F(2).a = -2.5;  F(2).b = 2.5;  F(2).x0 = 0.5;
F(2).xplot = [-2.6 2.6];      % zakres osi x na wykresie przeglądowym
F(2).opis  = 'dwa minima lokalne: globalne x≈-1.47, lokalne x≈1.35';

F(3).nazwa = 'f3: minimum na ograniczeniu';
F(3).wzor  = '(x-4)^2 + sin(2x)';
F(3).f     = @(x) (x - 4).^2 + sin(2*x);
F(3).a = 0;  F(3).b = 3;  F(3).x0 = 0.5;
F(3).xplot = [-0.5 6];      % zakres osi x na wykresie przeglądowym
F(3).opis  = 'bez ograniczeń: minima x≈3.03 i x≈4.92 – oba poza [0,3] → rozwiązanie x = 3 (ograniczenie aktywne)';

F(4).nazwa = 'f4: nieróżniczkowalna';
F(4).wzor  = '|x-1| + 0.3x^2';
F(4).f     = @(x) abs(x - 1) + 0.3*x.^2;
F(4).a = -2;  F(4).b = 3;  F(4).x0 = 2.5;
F(4).xplot = [-2.5 3.5];      % zakres osi x na wykresie przeglądowym
F(4).opis  = 'minimum x = 1 w punkcie „załamania” – brak pochodnej w minimum';
end
