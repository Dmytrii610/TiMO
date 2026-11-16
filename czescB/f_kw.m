function out = f_kw(varargin)
przesuniecie = [2, -3, 1];

if nargin == 0
    out = przesuniecie;
    return;
end

suma = 0;
for idx = 1:length(varargin)
    zmienna = varargin{idx};
    suma = suma + (zmienna - przesuniecie(idx)).^2;
end
out = suma;
end