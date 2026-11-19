function out = grad2_cust(xk, fun)
h = 1e-6;
n = length(xk);
out = zeros(n, 1);
for i = 1:n
    x_plus = xk;
    x_minus = xk;
    x_plus(i) = x_plus(i) + h;
    x_minus(i) = x_minus(i) - h;

    c_plus = num2cell(x_plus);
    c_minus = num2cell(x_minus);
    out(i) = (fun(c_plus{:}) - fun(c_minus{:})) / (2 * h);
end
end