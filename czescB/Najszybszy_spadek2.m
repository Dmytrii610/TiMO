% B - metoda najszybszego spadku z ograniczeniami kostkowymi lb <= x <= ub
%
% Krok:      x(k+1) = P( x(k) - alfa * f'(x(k)) / |f'(x(k))| )
%            P(x) = min(max(x, lb), ub) - rzut na zbiór dopuszczalny
% Długość kroku alfa wyznacza złoty podział na odcinku [0, alfa_max].
% Stop:      |P(x - grad) - x| < EPSILON   (gradient rzutowany ~ 0)
%            albo |x(k+1) - x(k)| < TOL_X  albo brak spadku f  albo MAX_ITER

%% ---------------- wybór zadania ----------------
n = input("Ile wymiarowa funkcja? (2 lub 3) \n");
if ~ismember(n, [2 3])
    fprintf("Nie zaimplementowano\n")
    return
end
fprintf("Która funkcja ma być sprawdzana? \n")
fprintf("1 - funkcja kwadratowa \n")
fprintf("2 - dropwave function \n")
fprintf("3 - funkcja Rosenbrocka \n")
n2 = input("Odpowiedź: \n");

switch n2
    case 1
        fun = @f_kw;
        lb = -5*ones(n, 1);   ub = 5*ones(n, 1);     % ograniczenia
        x_glob = f_kw();      x_glob = x_glob(1:n)';  % minimum bez ograniczeń
    case 2
        fun = @drop_wave_mdim;
        lb = -5*ones(n, 1);   ub = 5*ones(n, 1);
        x_glob = drop_wave_mdim();   x_glob = x_glob(1:n)';
    case 3
        fun = @rosenbrock;
        lb = -2*ones(n, 1);   ub = 2*ones(n, 1);
        x_glob = ones(n, 1);
    otherwise
        fprintf("Nie zaimplementowano \n")
        return
end

% Punkt startowy: wpisany ręcznie albo losowy z [lb, ub]
x0 = input("Punkt startowy jako wektor kolumnowy, np. [-1; 1] (Enter = losowy): \n");
if isempty(x0)
    x0 = lb + (ub - lb) .* rand(n, 1);
elseif numel(x0) ~= n
    fprintf("Punkt startowy musi mieć %d współrzędne\n", n)
    return
end
x0 = min(max(x0(:), lb), ub);                    % start musi być dopuszczalny

%% ---------------- parametry metody ----------------
EPSILON  = 1e-4;      % próg dla normy gradientu rzutowanego
TOL_X    = 1e-8;      % minimalna zmiana x
TOL_ALFA = 1e-6;      % dokładność złotego podziału (w jednostkach odległości)
KROK_0   = 1e-2;      % pierwszy próbny krok przy szukaniu przedziału
MAX_ITER = 5000;

P = @(x) min(max(x, lb), ub);                    % rzut na [lb, ub]
f = @(x) wywolaj(fun, x);                        % f(x) dla wektora x
alfa_max = norm(ub - lb);                        % najdłuższy sensowny krok = przekątna

%% ---------------- najszybszy spadek ----------------
xk = x0;
fk = f(xk);
sciezka = xk;
wartosci_f = fk;
iteracje = 0;
powod = "osiągnięto MAX_ITER";

fprintf("Punkt początkowy: \n");  disp(x0')

while iteracje < MAX_ITER
    grads = grad2_cust(xk, fun);
    if norm(P(xk - grads) - xk) < EPSILON
        powod = "gradient rzutowany < EPSILON";
        break
    end
    d   = -grads / norm(grads);                  % kierunek najszybszego spadku (długość 1)
    phi = @(a) f(P(xk + a*d));                   % f wzdłuż kierunku, z rzutem

    % 1) przedział [A, B] z minimum phi: podwajamy krok, dopóki f maleje
    [A, B] = szukaj_przedzialu(phi, fk, KROK_0, alfa_max);
    % 2) złoty podział na [A, B]
    alfa = B_zloty_podzial(phi, A, B, TOL_ALFA);
    if phi(alfa) >= fk
        powod = "brak spadku f wzdłuż kierunku";
        break
    end

    x_new = P(xk + alfa*d);
    dx = norm(x_new - xk);
    xk = x_new;
    fk = f(xk);
    iteracje = iteracje + 1;
    sciezka(:, end+1) = xk;            %#ok<SAGROW>
    wartosci_f(end+1) = fk;            %#ok<SAGROW>
    if dx < TOL_X
        powod = "zmiana x < TOL_X";
        break
    end
end

%% ---------------- wyniki ----------------
fprintf("Liczba iteracji: %d   (stop: %s)\n", iteracje, powod)
fprintf("Ostatecznie minimum znaleziono dla: \n");  disp(xk')
fprintf("z wartością: %.10g\n", fk)
na_brzegu = find(abs(xk - lb) < 1e-9 | abs(xk - ub) < 1e-9);
if ~isempty(na_brzegu)
    fprintf("Aktywne ograniczenia dla współrzędnych: %s\n", mat2str(na_brzegu'))
end
fprintf("Minimum globalne (bez ograniczeń): %s,  f = %.6g\n", mat2str(x_glob', 4), f(x_glob))
fprintf("Odległość od minimum globalnego: %.3e\n", norm(xk - x_glob))

%% ---------------- wykresy ----------------
siatka = @(i) linspace(lb(i), ub(i), 201);

if n == 2
    [X, Y] = meshgrid(siatka(1), siatka(2));
    Z = fun(X, Y);

    % Figure 1: powierzchnia 3D + ścieżka
    figure(1); clf;
    surf(X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.8);  hold on;
    plot3(sciezka(1,:), sciezka(2,:), wartosci_f, '-r.', 'LineWidth', 1.5, 'MarkerSize', 8);
    plot3(sciezka(1,1), sciezka(2,1), wartosci_f(1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    plot3(xk(1), xk(2), fk, 'b*', 'MarkerSize', 12, 'LineWidth', 2);
    plot3(x_glob(1), x_glob(2), f(x_glob), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    hold off;
    legend('Powierzchnia funkcji', 'Ścieżka algorytmu', 'Start', 'Znalezione minimum', ...
           'Minimum globalne', 'Location', 'best');
    title('Widok 3D funkcji celu');
    xlabel("x"); ylabel("y"); zlabel("f(x, y)");

    % Figure 2: poziomice + ścieżka + ograniczenia
    figure(2); clf;
    if n2 == 3
        contourf(X, Y, Z, logspace(-1, 3.5, 30));    % dolina Rosenbrocka
    else
        contourf(X, Y, Z, 30);
    end
    hold on;
    plot(sciezka(1,:), sciezka(2,:), '-r.', 'LineWidth', 1.5, 'MarkerSize', 8);
    plot(sciezka(1,1), sciezka(2,1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    plot(xk(1), xk(2), 'b*', 'MarkerSize', 10, 'LineWidth', 2);
    plot(x_glob(1), x_glob(2), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    rectangle('Position', [lb' (ub - lb)'], 'EdgeColor', 'k', 'LineWidth', 2, 'LineStyle', '--');
    hold off;
    colorbar;
    legend('Wartości funkcji', 'Ścieżka algorytmu', 'Start', 'Znalezione minimum', ...
           ['Minimum globalne ' mat2str(x_glob', 3)], 'Location', 'best');
    title('Ścieżka szukania minimum (przerywana ramka = ograniczenia)');
    xlabel('x'); ylabel('y');

else   % n == 3
    % Figure 1: przekrój f(x, y, z = z_końcowe) + rzut ścieżki na płaszczyznę xy
    [X, Y] = meshgrid(siatka(1), siatka(2));
    Z = fun(X, Y, xk(3)*ones(size(X)));
    figure(1); clf;
    contourf(X, Y, Z, 30);  hold on;
    plot(sciezka(1,:), sciezka(2,:), '-r.', 'LineWidth', 1.5, 'MarkerSize', 8);
    plot(sciezka(1,1), sciezka(2,1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    plot(xk(1), xk(2), 'b*', 'MarkerSize', 10, 'LineWidth', 2);
    hold off;  colorbar;
    title(sprintf('Przekrój f(x, y, z = %.4g) i rzut ścieżki na płaszczyznę xy', xk(3)));
    xlabel('x'); ylabel('y');
    legend('f(x, y, z_{końcowe})', 'Ścieżka (rzut)', 'Start', 'Znalezione minimum', 'Location', 'best');

    % Figure 2: ścieżka w przestrzeni 3D wewnątrz prostopadłościanu ograniczeń
    figure(2); clf;
    plot3(sciezka(1,:), sciezka(2,:), sciezka(3,:), '-r.', 'LineWidth', 1.5, 'MarkerSize', 10);
    hold on;
    plot3(sciezka(1,1), sciezka(2,1), sciezka(3,1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    plot3(xk(1), xk(2), xk(3), 'b*', 'MarkerSize', 10, 'LineWidth', 2);
    plot3(x_glob(1), x_glob(2), x_glob(3), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    rysuj_kostke(lb, ub);
    hold off;  grid on;  box on;  view(45, 30);
    legend('Ścieżka algorytmu', 'Start', 'Znalezione minimum', ...
           ['Minimum globalne ' mat2str(x_glob', 3)], 'Ograniczenia', 'Location', 'best');
    title('Ścieżka szukania minimum w przestrzeni 3D');
    xlabel('x'); ylabel('y'); zlabel('z');
end

% Figure 3: zbieżność
figure(3); clf;
semilogy(0:iteracje, wartosci_f - min(wartosci_f) + eps, '-b.');
grid on;
title('Zbieżność: f(x_k) - f(x_{końcowe})');
xlabel('iteracja k'); ylabel('f(x_k) - f_{min}');

%% ================= funkcje lokalne =================
function y = wywolaj(fun, x)
% f(x) dla wektora x - funkcje celu przyjmują współrzędne jako osobne argumenty
c = num2cell(x);
y = fun(c{:});
end

function [A, B] = szukaj_przedzialu(phi, f0, krok, krok_max)
% Przedział [A, B] zawierający najbliższe minimum phi(alfa), alfa >= 0.
% Krok jest podwajany, dopóki phi maleje; pierwszy wzrost zamyka przedział.
if phi(krok) >= f0                 % już pierwszy krok za duży
    A = 0;   B = krok;
    return
end
t_pp = 0;   t_p = krok;   f_p = phi(krok);
while true
    t = min(2*t_p, krok_max);
    f_t = phi(t);
    if f_t >= f_p || t >= krok_max
        break
    end
    t_pp = t_p;   t_p = t;   f_p = f_t;
end
A = t_pp;   B = t;                 % minimum leży między t_pp a t
end

function rysuj_kostke(lb, ub)
% 12 krawędzi prostopadłościanu [lb, ub] w 3D
[a, b] = deal(lb, ub);
V = [a(1) a(2) a(3); b(1) a(2) a(3); b(1) b(2) a(3); a(1) b(2) a(3)
     a(1) a(2) b(3); b(1) a(2) b(3); b(1) b(2) b(3); a(1) b(2) b(3)];
E = [1 2; 2 3; 3 4; 4 1; 5 6; 6 7; 7 8; 8 5; 1 5; 2 6; 3 7; 4 8];
for i = 1:size(E, 1)
    h = plot3(V(E(i,:), 1), V(E(i,:), 2), V(E(i,:), 3), 'k--');
    if i > 1, set(h, 'HandleVisibility', 'off'); end
end
end