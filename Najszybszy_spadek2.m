% B - steepest descent method (zaktualizowany)
n = input("Ile wymiarowa funkcja? \n");
fprintf("Która funkcja ma być sprawdzana? \n")
fprintf("1 - funkcja kwadratowa \n")
fprintf("2 - dropwave function \n")
fprintf("3 - funkcja Rosenbrocka \n")
n2 = input("Odpowiedź: \n");

switch n2
    case 1
        fun = @f_kw;
    case 2
        fun = @drop_wave_mdim;
    case 3
        fun = @rosenbrock;
    otherwise
        fprintf("Nie zaimplementowano \n")
        return
end

switch n
    case 2
        figure(1);
        surf(X, Y, z, 'EdgeColor', 'none', 'FaceAlpha', 0.8);
        title('Widok 3D funkcji celu');
        xlabel("x"); ylabel("y"); zlabel("f(x, y)");
        
        % Dopasowanie dziedziny w zależności od wybranej funkcji
        if n2 == 3
            Left_bndrs = [-2 -1]; % Lepsze granice dla doliny Rosenbrocka
            Right_bndrs = [2 3];
        else
            %Left_bndrs = [-5 -5];
            %Right_bndrs = [5 5];
            Left_bndrs_start = [-0.5 -0.5];
            Right_bndrs_start = [0.5 0.5];
        end
        
        podstawy = [Left_bndrs(1):0.05:Right_bndrs(1)
                    Left_bndrs(2):0.05:Right_bndrs(2)];
                
        %x0 = [(Right_bndrs(1)-Left_bndrs(1)).*rand()+Left_bndrs(1)
              %(Right_bndrs(2)-Left_bndrs(2)).*rand()+Left_bndrs(2)];
        x0 = [(Right_bndrs_start(1)-Left_bndrs_start(1)).*rand()+Left_bndrs_start(1)
              (Right_bndrs_start(2)-Left_bndrs_start(2)).*rand()+Left_bndrs_start(2)];
        
        [X,Y] = meshgrid(podstawy(1, :), podstawy(2, :));
        z = fun(X, Y);
        
        % Opcjonalny podgląd 3D na początku
        figure(1);
        surf(X, Y, z, 'EdgeColor', 'none');
        title('Widok 3D funkcji celu');
        xlabel("x"); ylabel("y"); zlabel("f(x, y)");
        
    case 3
        if n2 == 3
            Left_bndrs = [-2 -2 -2]; 
            Right_bndrs = [2 2 2];
        else
            Left_bndrs = [-5 -5 -5];
            Right_bndrs = [5 5 5];
        end
        
        podstawy = [Left_bndrs(1):0.05:Right_bndrs(1)
                    Left_bndrs(2):0.05:Right_bndrs(2)
                    Left_bndrs(3):0.05:Right_bndrs(3)];
                
        x0 = [(Right_bndrs(1)-Left_bndrs(1)).*rand()+Left_bndrs(1)
              (Right_bndrs(2)-Left_bndrs(2)).*rand()+Left_bndrs(2) 
              (Right_bndrs(3)-Left_bndrs(3)).*rand()+Left_bndrs(3)];
          
        [X,Y] = meshgrid(podstawy(1, :), podstawy(2, :));
        [Y2,Z] = meshgrid(podstawy(2, :), podstawy(3, :));
        c = fun(X, Y, Z);
        
        figure(1);
        surf(X, Y, c, Z);
        xlabel("x"); ylabel("y"); zlabel("f(x, y, z)");
        cb = colorbar;
        cb.Label.String = "z";
    otherwise
        fprintf("Nie zaimplementowano\n")
        return
end

fprintf("Punkt początkowy: \n")
disp(x0)

xk = x0;
r = size(xk);
EPSILON = 0.01 * r(1); 
kontury_x = xk;

% UWAGA
grads = grad2_cust(xk, fun); 
iteracje = 0;

% Dodano zabezpieczenie przed nieskończoną pętlą (max 2000 iteracji)
while dlugosc(grads) > EPSILON && iteracje < 2000
    alfa = B_zloty_podzial(fun, xk, grads);
    xk = xk - alfa * grads;
    kontury_x(:, end + 1) = xk;     
    grads = grad2_cust(xk, fun);
    iteracje = iteracje + 1;
end

fprintf("Liczba iteracji: " + num2str(iteracje) + "\n")
fprintf("Ostatecznie minimum znaleziono dla: \n")
disp(xk)
fprintf("z wartością: \n")
xk_cell = num2cell(xk);
disp(fun(xk_cell{:}))

% Wizualizacja 2D ścieżki optymalizacji
if n == 2
    kc = kontury_x; 
    x = kc(1, :);
    y = kc(2, :);
    
    figure(2); % Otwieramy nowe okno dla mapy
    
    % --- NOWY KOD: Dodanie punktów i ścieżki na wykres 3D (Figure 1) ---
    figure(1);
    hold on;

    % Obliczenie wysokości (wartości funkcji) dla każdego kroku ścieżki
    z_sciezka = fun(x, y);

    % Rysowanie ścieżki 3D na powierzchni (opcjonalnie - bardzo pomaga w analizie)
    plot3(x, y, z_sciezka, '-r.', 'LineWidth', 1.5, 'MarkerSize', 8);

    % 1. Punkt startowy (zielone kółko)
    plot3(x(1), y(1), z_sciezka(1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');

    % 2. Minimum znalezione przez algorytm (niebieska gwiazdka)
    plot3(x(end), y(end), z_sciezka(end), 'b*', 'MarkerSize', 12, 'LineWidth', 2);

    % 3. Minimum globalne (czarny kwadrat)
    if n2 == 3
        plot3(1, 1, fun(1, 1), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    elseif n2 == 1
        plot3(0, 0, fun(0, 0), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    elseif n2 == 2
        min_glob = fun();
        plot3(min_glob(1), min_glob(2), fun(min_glob(1), min_glob(2)), ...
            'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    end

    legend('Powierzchnia funkcji', 'Ścieżka algorytmu', 'Punkt startowy', ...
        'Znalezione minimum', 'Minimum globalne', 'Location', 'best');
    hold off;

    % Dla funkcji Rosenbrocka używamy logarytmicznej mapy poziomicowej
    if n2 == 3
        poziomy = logspace(-1, 3.5, 30);
        contourf(X, Y, z, poziomy);
    else
        % Dla reszty standardowe poziomice
        contourf(X, Y, z, 30);
    end
    
    hold on;
    % Rysowanie ścieżki (zoptymalizowany zapis bez pętli for)
    plot(x, y, '-r.', 'LineWidth', 1.5, 'MarkerSize', 8);
    
    % Oznaczenie punktu startowego (zielone kółko) i końcowego (niebieska gwiazdka)
    plot(x(1), y(1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    plot(x(end), y(end), 'b*', 'MarkerSize', 10, 'LineWidth', 2);
    
    % Oznaczenie globalnego minimum z definicji dla Rosenbrocka i f_kw
    if n2 == 3
        plot(1, 1, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
        legend('Wartości funkcji', 'Ścieżka algorytmu', 'Start', 'Koniec (Minimum lokalne)', 'Minimum globalne (1,1)');
    elseif n2 == 1
        plot(0, 0, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
        legend('Wartości funkcji', 'Ścieżka algorytmu', 'Start', 'Koniec (Minimum lokalne)', 'Minimum globalne (0,0)');
    elseif n2 == 2
        min_glob = fun();

        plot(min_glob(1), min_glob(2), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
        legend('Wartości funkcji', 'Ścieżka algorytmu', 'Start', 'Koniec (Minimum lokalne)', ...
            ['Minimum globalne (' num2str(min_glob(1)) ', ' num2str(min_glob(2)) ')']);

        fprintf("\n[Informacja] Teoretyczne minimum globalne Drop-Wave: x = %.2f, y = %.2f\n", min_glob(1), min_glob(2));
    end
    
    hold off;
    colorbar;
    title('Ścieżka szukania minimum');
    xlabel('x'); 
    ylabel('y');

elseif n == 3
    kc = kontury_x;
    x = kc(1, :);
    y = kc(2, :);
    z_traj = kc(3, :);

    figure(2);
    plot3(x, y, z_traj, '-r.', 'LineWidth', 1.5, 'MarkerSize', 10);
    hold on;

    plot3(x(1), y(1), z_traj(1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    plot3(x(end), y(end), z_traj(end), 'b*', 'MarkerSize', 10, 'LineWidth', 2);

    if n2 == 3
        plot3(1, 1, 1, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
        legend('Ścieżka algorytmu', 'Start', 'Koniec (Minimum lokalne)', 'Minimum globalne (1, 1, 1)');
    elseif n2 == 1
        plot3(0, 0, 0, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
        legend('Ścieżka algorytmu', 'Start', 'Koniec (Minimum lokalne)', 'Minimum globalne (0, 0, 0)');
    elseif n2 == 2
        min_glob = fun();
        plot3(min_glob(1), min_glob(2), min_glob(3), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
        legend('Ścieżka algorytmu', 'Start', 'Koniec (Minimum lokalne)', ...
            ['Minimum globalne (' num2str(min_glob(1)) ', ' num2str(min_glob(2)) ', ' num2str(min_glob(3)) ')']);
    end

    hold off;
    grid on;
    box on;
    view(45, 30);
    title('Ścieżka szukania minimum w przestrzeni 3D');
    xlabel('x');
    ylabel('y');
    zlabel('z');
end

