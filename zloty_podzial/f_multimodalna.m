function y = f_multimodalna(x)
%Multimodalna funkcja celu (dwa minima lokalne): f(x) = x^4 - 4x^2 + x
%     x ~= -1.473  – minimum globalne,
%     x ~=  0.126  – maksimum lokalne,
%     x ~=  1.347  – minimum lokalne,
%   Dokładne wartości: roots([4 0 -8 1]).
%   Funkcja przyjmuje wektory.
y = x.^4 - 4*x.^2 + x;
end
