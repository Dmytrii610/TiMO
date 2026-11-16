function out = f_kw(varargin)
przesuniecie = [2, -3]; 
% nowe współrzędne minimum (dla 2D weźmie pierwsze dwie)
suma = 0;

for idx = 1:length(varargin)
    zmienna = varargin{idx};
    suma = suma + (zmienna - przesuniecie(idx)).^2;
end
out = suma;
end
%----------------------------------
%{
suma = 0;
for i=varargin
    
    if iscell(i)
        suma = suma + cell2mat(i).^2;
    else
        suma = suma + i.^2;
    end
end
out = suma;

end
%}
%------------------------------
