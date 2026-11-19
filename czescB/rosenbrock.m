function out = rosenbrock(varargin)
% Parametry standardowe: a = 1, b = 100
a = 1;
b = 100;

suma = 0;
n = length(varargin);

for idx = 1:(n - 1)
    x_curr = varargin{idx};
    x_next = varargin{idx + 1};

    suma = suma + b * ((x_next - x_curr.^2).^2) + (a - x_curr).^2;
end

out = suma;
end