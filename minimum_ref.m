function [xr, fr] = minimum_ref(Fi)
% MINIMUM_REF  Minimum referencyjne (globalne) na [a,b]: gęsta siatka + doprecyzowanie.
xx = linspace(Fi.a, Fi.b, 20001);
[~, i] = min(wartosci(Fi.f, xx));
h  = xx(2) - xx(1);
lo = max(Fi.a, xx(i) - h);  hi = min(Fi.b, xx(i) + h);
Z  = zloty_podzial(Fi.f, lo, hi, 1e-12, 200);
xr = Z.xopt;  fr = Z.fopt;
if Fi.f(Fi.a) < fr, xr = Fi.a; fr = Fi.f(xr); end
if Fi.f(Fi.b) < fr, xr = Fi.b; fr = Fi.f(xr); end
end
