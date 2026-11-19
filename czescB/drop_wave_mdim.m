function out = drop_wave_mdim(varargin)
% --- PARAMETRY DO ZMIANY ---
czestotliwosc = 2;          % domyślnie 12 (mniejsza = mniej minimów lokalnych)
tlumienie = 0.5;            % domyślnie 0.5 (większa = szybsze wypłaszczenie)
przesuniecie = [0.5, -2, 0]; % nowe współrzędne minimum globalnego
% ---------------------------

% Przekazanie minimum do głównego pliku

if nargin == 0
    out = przesuniecie;
    return;
end

suma = 0;
for idx = 1:length(varargin)
    zmienna = varargin{idx};
    % odejmujemy przesunięcie, aby przenieść środek fal
    suma = suma + (zmienna - przesuniecie(idx)).^2;
end

f1 = -(1 + cos(czestotliwosc * sqrt(suma)));
f2 = tlumienie * suma + 2;
out = f1 ./ f2;
end

%{
suma = 0;
suma2 = 0;
for i=varargin
    
    if iscell(i)
        suma2 = suma2 + 2.*cell2mat(i).^2;
        suma = suma + cell2mat(i).^2;
    else
        suma2 = suma2 + 2.*i.^2;
        suma = suma + i.^2;
    end
    
end

f1 = -(1+cos(12*sqrt(suma2)));
f2 = 0.5.*(suma) + 2;
out = f1./f2;

end
%}
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%{
if nargin == 2
    x = varargin{1};
    y = varargin{2};
    f1 = -(1+cos(12*sqrt(2.*x.^2 + 2.*y.^2)));
    f2 = 0.5.*(x.^2 + y.^2) + 2;
    out = f1./f2;
else
    % założenie, że 3
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
    f1 = -(1+cos(12*sqrt(2.*x.^2 + 2.*y.^2 + 2.*z.^2)));
    f2 = 0.5.*(x.^2 + y.^2 + z.^2) + 2;
    out = f1./f2;

%}