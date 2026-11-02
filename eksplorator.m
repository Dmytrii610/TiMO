function fig = eksplorator(F, par)
% EKSPLORATOR  Okno interaktywne: wybór funkcji (także własnej), metody,
% parametrów; suwak iteracji i animacja przebiegu algorytmu.
if nargin < 1 || isempty(F),   F = funkcje_testowe();      end
if nargin < 2 || isempty(par), par = domyslne_parametry(); end

fig = uifigure('Name', 'Optymalizacja 1D – eksplorator metod', ...
               'Position', [60 60 1300 780]);
g = uigridlayout(fig, [1 2]);
g.ColumnWidth = {330, '1x'};

% ---------------- panel ustawień ----------------
p  = uipanel(g, 'Title', 'Ustawienia');
gp = uigridlayout(p, [16 2]);
gp.RowHeight   = [repmat({24}, 1, 12), {30, 22, 50, '1x'}];
gp.ColumnWidth = {125, '1x'};
gp.RowSpacing  = 6;

nazwy = [{F.nazwa}, {'własna funkcja…'}];
U.ddF  = poz(uidropdown(gp, 'Items', nazwy, 'ItemsData', 1:numel(nazwy), 'Value', 1), 1, 2);
poz(uilabel(gp, 'Text', 'Funkcja celu'), 1, 1);
poz(uilabel(gp, 'Text', 'własna f(x) ='), 2, 1);
U.edW  = poz(uieditfield(gp, 'text', 'Value', 'x.^4 - 4*x.^2 + x', 'Enable', 'off', ...
             'Tooltip', 'wyrażenie w zmiennej x, np. sin(3*x) + 0.1*x.^2'), 2, 2);
poz(uilabel(gp, 'Text', 'Metoda'), 3, 1);
U.ddM  = poz(uidropdown(gp, 'Items', {'Złoty podział', 'Gradient', 'Powell', 'Wszystkie trzy'}, ...
             'ItemsData', {'zloty', 'gradient', 'powell', 'wszystkie'}, 'Value', 'zloty'), 3, 2);
etyk = {'a (lewy koniec)', 'b (prawy koniec)', 'x0 (start)', 'tol', 'maxIter', ...
        'α (krok gradientu)', 'Δ (krok Powella)'};
wart = {F(1).a, F(1).b, F(1).x0, par.tol, par.maxIter, par.alfa, par.delta};
pola = {'a', 'b', 'x0', 'tol', 'maxIter', 'alfa', 'delta'};
for i = 1:numel(pola)
    poz(uilabel(gp, 'Text', etyk{i}), 3 + i, 1);
    U.(pola{i}) = poz(uieditfield(gp, 'numeric', 'Value', wart{i}), 3 + i, 2);
end
U.tol.ValueDisplayFormat = '%.1e';
U.maxIter.Limits = [1 1e5];   U.maxIter.RoundFractionalValues = 'on';
U.tol.Limits = [1e-14 1];     U.alfa.Limits = [1e-6 100];   U.delta.Limits = [1e-6 100];
U.cbOgr = poz(uicheckbox(gp, 'Text', 'ograniczenia a ≤ x ≤ b (gradient, Powell)', ...
              'Value', par.ograniczenia), 11, [1 2]);
U.cbArm = poz(uicheckbox(gp, 'Text', 'krok Armijo (backtracking) w gradiencie', ...
              'Value', par.armijo), 12, [1 2]);
U.btnOb = poz(uibutton(gp, 'Text', 'Oblicz'), 13, 1);
U.btnAn = poz(uibutton(gp, 'Text', '▶ Animuj'), 13, 2);
U.lblK  = poz(uilabel(gp, 'Text', 'Iteracja k = 0', 'FontWeight', 'bold'), 14, [1 2]);
U.sl    = poz(uislider(gp, 'Limits', [0 1], 'Value', 0), 15, [1 2]);
U.txt   = poz(uitextarea(gp, 'Editable', 'off', 'FontSize', 11), 16, [1 2]);

% ---------------- wykresy ----------------
gr = uigridlayout(g, [2 1]);
gr.RowHeight = {'3x', '2x'};
U.ax1 = uiaxes(gr);
U.ax2 = uiaxes(gr);

% ---------------- stan i wywołania zwrotne ----------------
D = struct('F', F, 'U', U, 'Ws', {{}}, 'Fi', [], 'par', par, 'xr', NaN, 'anim', false);
fig.UserData = D;

U.ddF.ValueChangedFcn   = @(s, e) zmiana_funkcji(fig);
U.edW.ValueChangedFcn   = @(s, e) przelicz(fig);
U.ddM.ValueChangedFcn   = @(s, e) przelicz(fig);
for i = 1:numel(pola)
    U.(pola{i}).ValueChangedFcn = @(s, e) przelicz(fig);
end
U.cbOgr.ValueChangedFcn = @(s, e) przelicz(fig);
U.cbArm.ValueChangedFcn = @(s, e) przelicz(fig);
U.btnOb.ButtonPushedFcn = @(s, e) przelicz(fig);
U.btnAn.ButtonPushedFcn = @(s, e) animuj(fig);
U.sl.ValueChangingFcn   = @(s, e) rysuj_k(fig, e.Value);
U.sl.ValueChangedFcn    = @(s, e) rysuj_k(fig, s.Value);

przelicz(fig);
end

% ======================================================================
function c = poz(c, r, k)
c.Layout.Row = r;   c.Layout.Column = k;
end

function zmiana_funkcji(fig)
D = fig.UserData;  U = D.U;  i = U.ddF.Value;
wlasna = i > numel(D.F);
if wlasna, U.edW.Enable = 'on'; else, U.edW.Enable = 'off'; end
if ~wlasna
    U.a.Value = D.F(i).a;   U.b.Value = D.F(i).b;   U.x0.Value = D.F(i).x0;
end
przelicz(fig);
end

function przelicz(fig)
D = fig.UserData;  U = D.U;
% --- funkcja celu ---
i = U.ddF.Value;
if i <= numel(D.F)
    Fi = D.F(i);
else
    try
        f = str2func(['@(x) ' U.edW.Value]);
        f(U.a.Value);                                  % test poprawności wyrażenia
    catch ME
        uialert(fig, ['Niepoprawne wyrażenie: ' ME.message], 'Własna funkcja');
        return
    end
    Fi = struct('nazwa', 'własna', 'wzor', U.edW.Value, 'f', f, 'a', 0, 'b', 1, ...
                'x0', 0, 'opis', '', 'xplot', []);
end
Fi.a = U.a.Value;   Fi.b = U.b.Value;   Fi.x0 = U.x0.Value;
if Fi.b <= Fi.a
    uialert(fig, 'Musi zachodzić a < b.', 'Przedział');
    return
end
% --- parametry ---
par = D.par;
par.tol = U.tol.Value;          par.maxIter = round(U.maxIter.Value);
par.alfa = U.alfa.Value;        par.delta = U.delta.Value;
par.ograniczenia = U.cbOgr.Value;  par.armijo = U.cbArm.Value;
% --- obliczenia ---
if strcmp(U.ddM.Value, 'wszystkie'), M = {'zloty', 'gradient', 'powell'}; else, M = {U.ddM.Value}; end
try
    Ws = cellfun(@(m) uruchom_metode(m, Fi, par), M, 'UniformOutput', false);
    [xr, fr] = minimum_ref(Fi);
catch ME
    uialert(fig, ME.message, 'Błąd obliczeń');
    return
end
kmax = max(cellfun(@(W) W.iter, Ws));
U.sl.Value  = 0;
U.sl.Limits = [0 max(kmax, 1)];
U.sl.MajorTicks = unique(round(linspace(0, max(kmax, 1), min(max(kmax, 1), 10) + 1)));
U.sl.MinorTicks = [];
U.sl.Value  = kmax;
% --- podsumowanie ---
s = {sprintf('x_ref = %.8f   (min. globalne na [a,b])', xr), sprintf('f_ref = %.8f', fr), ''};
for j = 1:numel(Ws)
    W = Ws{j};
    s = [s, {sprintf('%s', upper(W.metoda)), ...
             sprintf('  x*    = %.8f', W.xopt), ...
             sprintf('  f(x*) = %.8f', W.fopt), ...
             sprintf('  błąd  = %.2e', abs(W.xopt - xr)), ...
             sprintf('  iter. = %d,  obl. f = %d', W.iter, W.nf), ...
             sprintf('  stop: %s', W.stop), ''}]; %#ok<AGROW>
end
U.txt.Value = s;
D.Fi = Fi;  D.Ws = Ws;  D.par = par;  D.xr = xr;
fig.UserData = D;
rysuj_k(fig, kmax);
end

function rysuj_k(fig, k)
if ~isvalid(fig), return; end
D = fig.UserData;
if isempty(D.Ws), return; end
k = round(k);
if numel(D.Ws) == 1
    rysuj_metode(D.U.ax1, D.Fi, D.Ws{1}, k, D.par);
else
    rysuj_wszystkie(D.U.ax1, D.Fi, D.Ws, k, D.par);
end
rysuj_zbieznosc(D.U.ax2, D.Ws, D.xr, k);
D.U.lblK.Text = sprintf('Iteracja k = %d', k);
end

function animuj(fig)
D = fig.UserData;
if D.anim                          % drugie kliknięcie = zatrzymaj animację
    D.anim = false;  fig.UserData = D;
    return
end
D.anim = true;  fig.UserData = D;
D.U.btnAn.Text = '■ Stop';
kmax = round(D.U.sl.Limits(2));
for k = 0:kmax
    if ~isvalid(fig) || ~fig.UserData.anim, break; end
    D.U.sl.Value = k;
    rysuj_k(fig, k);
    drawnow;
    pause(max(0.05, min(0.4, 6/max(kmax, 1))));
end
if isvalid(fig)
    D = fig.UserData;  D.anim = false;  fig.UserData = D;
    D.U.btnAn.Text = '▶ Animuj';
end
end
