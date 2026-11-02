function y = wartosci(f, x)
% WARTOSCI  Wartości f w punktach x (działa także dla funkcji niewektorowych).
try
    y = f(x);
    if ~isequal(size(y), size(x)), y = arrayfun(f, x); end
catch
    y = arrayfun(f, x);
end
end
