function out = B_zloty_podzial(funk, xk, grads)

%---------------wersja1

A = 0 + eps;
B = 5;          % Pamiętaj o zmniejszeniu kroku! (np. 1 lub 0.5)
k = 0.618034;   % Proporcja złotego podziału
EPSILON = 0.001;

% Wyznaczenie pierwszych punktów przed pętlą
lambda1 = B - (B - A) * k;
lambda2 = A + (B - A) * k;

% Pierwsze podwójne wyliczenie (tylko raz!)
arg1 = num2cell(xk - lambda1 * grads);
arg2 = num2cell(xk - lambda2 * grads);
val1 = funk(arg1{:});
val2 = funk(arg2{:});

while abs(B - A) > EPSILON
    if val1 > val2 
        % Przesuwamy lewą granicę (A) w prawo
        A = lambda1;

        % Stary prawy punkt (lambda2) staje się nowym lewym
        lambda1 = lambda2;
        val1 = val2; % PRZEPISANIE WARTOŚCI - brak wywoływania funkcji celu!

        % Liczymy tylko nowy prawy punkt
        lambda2 = A + (B - A) * k;
        arg2 = num2cell(xk - lambda2 * grads);
        val2 = funk(arg2{:});
    else
        % Przesuwamy prawą granicę (B) w lewo
        B = lambda2;

        % Stary lewy punkt (lambda1) staje się nowym prawym
        lambda2 = lambda1;
        val2 = val1; % PRZEPISANIE WARTOŚCI - brak wywoływania funkcji celu!

        % Liczymy tylko nowy lewy punkt
        lambda1 = B - (B - A) * k;
        arg1 = num2cell(xk - lambda1 * grads);
        val1 = funk(arg1{:});
    end
end

out = (A + B) / 2;
end

%---------------wersja2    
%{    
    A = 0 + eps;
    B = 50;
    k = 0.618034;
    EPSILON = 0.001;
    
    liczba_krokow = 0;
    while abs(B - A) > EPSILON
    
        lambda1 = B - (B - A)*k;
        lambda2 = A + (B - A)*k;

        arg1 = xk - lambda1*grads;
        arg1_cell = num2cell(arg1);
        arg2 = xk - lambda2*grads;
        arg2_cell = num2cell(arg2);

        val1 = funk(arg1_cell{:});
        val2 = funk(arg2_cell{:});
        liczba_krokow = liczba_krokow + 1;
    
        if val1 > val2 
            A = lambda1;
        else
            B = lambda2;
        end
    end
   
    out = (A+B)/2;

end
%}