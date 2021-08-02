clc; clear all; close all;

% Niniejszy skrypt s³u¿y do obliczeñ eksperymentu
% numerycznego zaprojektowanego na potrzeby pracy
% magisterskiej. Przyjêto funkcjê regresji w postaci
% funkcji dwóch zmiennych: y = f (x1, x2)

%% Deklaracja zmiennych eksperymentu

densityMin = 7750; densityMax = 7890;
YoungModulusMin = 187; YoungModulusMax = 213;

densityMean = (densityMax + densityMin) ./ 2;
densityStep = (densityMax - densityMin) ./ 2;
YoungModulusMean = (YoungModulusMax + YoungModulusMin) ./ 2;
YoungModulusStep = (YoungModulusMax - YoungModulusMin) ./ 2;

% Wektory zmiennych standaryzowanych

densityStandard = [-1, -1, -sqrt(2)./2, -sqrt(2)./2, 0, sqrt(2)./2, sqrt(2)./2, 1, 1];
YoungModulusStandard = [-1, 1, -sqrt(2)./2, sqrt(2)./2, 0, -sqrt(2)./2, sqrt(2)./2, -1, 1];

% Wektory gêstoœci i modu³u Young'a dla poszczególnych doœwiadczeñ

densityVector = [7750, 7750, 7770.5025, 7770.5025, 7820, 7869.4975, 7869.4975, 7890, 7890]';
YoungModulusVector = [187, 213, 190.8076, 209.1924, 200, 190.8076, 209.1924, 187, 213]';

% Czêstotliwoœci uzyskane z eksperymentu

modalFreq = [424.477, 453.026, 428.210, 448.366, 437.014, 425.509, 445.537, 420.694, 448.989]';

%% Wizualizacja zmiennych wejœciowych

standardCircleVariable = 0:0.01:2*pi;

figure(1);
plot(densityVector, YoungModulusVector, 'r*', 'LineWidth', 1);
grid on; hold on;
plot(densityStep .* cos(standardCircleVariable) + densityMean, YoungModulusStep .* sin(standardCircleVariable) + YoungModulusMean, 'k--', 'LineWidth', 1);
xlabel('Gêstoœæ \rho [kg/m^3]'); ylabel('Modu³ Younga E [GPa]');
axis([densityMin, densityMax, YoungModulusMin, YoungModulusMax]);

figure(2);
plot(cos(standardCircleVariable), sin(standardCircleVariable), 'b--');
axis([-1, 1, -1, 1]); axis equal;
grid on; hold on; pbaspect([1 1 1]);
plot(densityStandard, YoungModulusStandard, 'r*');

%% Deklaracja macierzy zmiennych

X = [ones(length(densityVector), 1), densityVector, YoungModulusVector, densityVector.^2, YoungModulusVector.^2, densityVector.^3, YoungModulusVector.^3, densityVector.*YoungModulusVector.^2, YoungModulusVector.*densityVector.^2]; % Macierz wejœæ
Y = modalFreq; % MAcierz wyjœcia

%% Wyznaczenie wspo³czynników funkcji regresji

A = (X' * X) \ X' * Y;

%% Obliczenie wyników eksperymentu

modalFreqExp = X * A;

%% Wyznaczenie powierzchni odpowiedzi

densityStep = (max(densityVector) - min(densityVector)) ./ (length(densityVector) - 1);
YoungModulusStep = (max(YoungModulusVector) - min(YoungModulusVector)) ./ (length(YoungModulusVector) - 1);

xInitial = densityVector(1):(densityStep ./ 20):densityVector(9);
yInitial = YoungModulusVector(1):(YoungModulusStep ./ 20):YoungModulusVector(9);

[xPlot, yPlot] = meshgrid(xInitial, yInitial);
z = @(x, y) A(1) + A(2) .* x + A(3) .* y + A(4) .* x.^2 + A(5) .* y.^2 + A(6) .* x.^3 + A(7) .* y.^3 + A(8) .* x.*y.^2 + A(9) .* y.*x.^2;
zPlot = z(xPlot, yPlot);

%% Wizualizacja powierzchni odpowiedzi

figure(3);
surf(xPlot, yPlot, zPlot, 'EdgeColor', 'none'); hold on;
plot3(densityVector, YoungModulusVector, modalFreq, 'r*'); grid on;
xlabel('Gêstoœæ \rho [kg / m^3]'); ylabel('Modu³ Younga E [Pa]');
zlabel('Czêstotliwoœæ f [Hz]'); pbaspect([1 1 1]);

%% Sprawdzanie zgodnoœci

[xVerify, yVerify] = meshgrid(densityVector, YoungModulusVector);
zVerify = z(xVerify, yVerify);

% Wykres residuów

figure(4);
plot(modalFreq, diag(zVerify), 'r*');
axis([420, 455, 420, 455]); grid on; hold on;
xlabel('Wyniki z eksperymentu'); ylabel('Wyniki z funkcji regresji');
line([420, 455], [420, 455]); pbaspect([1 1 1]);

% Wspó³czynnik determinacji R2

zVerifyMean = mean(diag(zVerify));
R2 = sum((diag(zVerify) - zVerifyMean).^2) ./ sum((modalFreq - zVerifyMean).^2);

%% Odczytanie najlepszych wartoœci gêstoœci i modu³u Younga

results = zPlot;

frequencyRelativeError_Density = abs(440 - zPlot) ./ 440 .* 100; % B³¹d wzglêdny powierzchni odpowiedzi dla gêstoœci
rowMostAccurateRelativeError_Density = min(frequencyRelativeError_Density);
[mostAccurateRelativeError_Density, mostAccurateRelativeErrorIndeces_Density] = min(rowMostAccurateRelativeError_Density);
mostAccurateDensity = xInitial(mostAccurateRelativeErrorIndeces_Density);

frequencyRelativeError_Young = abs(440 - zPlot') ./ 440 .* 100; % B³¹d wzglêdny powierzchni odpowiedzi dla modu³u Younga
rowMostAccurateRelativeError_Young = min(frequencyRelativeError_Young);
[mostAccurateRelativeError_Young, mostAccurateRelativeErrorIndeces_Young] = min(rowMostAccurateRelativeError_Young);
mostAccurateYoungModulus = yInitial(mostAccurateRelativeErrorIndeces_Young);
