clc; clear all; close all;

% Niniejszy skrypt pozwala na wyznaczenie
% wspó³czynnika t³umienia wykorzystuj¹c
% logarytmiczny dekrement t³umienia

%% Wczytywanie danych sygna³u z pliku .wav

[y1, fs1] = audioread('Pomiar_Gora.wav');
[y2, fs2] = audioread('Pomiar_Przod.wav');
[y3, fs3] = audioread('Pomiar_Tyl.wav');
[y4, fs4] = audioread('Pomiar_Lewo.wav');
[y5, fs5] = audioread('Pomiar_Prawo.wav');
FS = [fs1 fs2 fs3 fs4 fs5]; % Wektor czêst. próbkowania
Y = cell(1, 5); % Macierz komórkowa sygna³ów
Y{1} = y1; Y{2} = y2; Y{3} = y3;
Y{4} = y4; Y{5} = y5;

%% Wyznaczenie dziedziny czasu

n1 = 776347; n2 = 874267; n3 = 698907;
n4 = 764827; n5 = 739227;
N = [n1 n2 n3 n4 n5]; % Wektor liczby próbek
tp = 0; % Czas rozpoczêcia pomiaru
T = cell(1, 5); % Macierz komórkowa czasu

for i = 1:1:5
    krok = 1 / FS(i); % Krok czasowy
    tk = (N(i) - 1) / FS(i); % Czas zakoñczenia pomiaru
    t = tp:krok:tk; t = t'; % Wektor czasu
    T{i} = t;
end;

%% Wizualizacja sygna³ów

for i = 1:1:5
    nPlot = 1:1:N(i); t = T{i}; y = Y{i};
    figure(i); plot(nPlot, y); grid on; hold on;
    xlabel('Numer próbki'); ylabel('Amplituda drgañ');
end;

%% Wyznaczenie fragmentu sygna³ów i ich wizualizacja

YMeasure = cell(1, 5); % Macierz komórkowa fragmentów sygna³u
index = cell(1, 5); % Macierz komórkowa indeksów fragmentów

YMeasure{1} = y1(119200:490800); index{1} = 1:1:length(YMeasure{1});
YMeasure{2} = y2(154800:626900); index{2} = 1:1:length(YMeasure{2});
YMeasure{3} = y3(124400:397800); index{3} = 1:1:length(YMeasure{3});
YMeasure{4} = y4(115300:539500); index{4} = 1:1:length(YMeasure{4});
YMeasure{5} = y5(102100:402200); index{5} = 1:1:length(YMeasure{5});

%% Wizualizacja fragmentów

for i = 1:1:5
    nPlot = 1:1:length(index{i}); y = YMeasure{i};
    figure(i + 5); plot(nPlot, y); grid on; hold on;
    xlabel('Numer próbki'); ylabel('Amplituda drgañ');
end;

figure(11); subplot(5, 1, 1); plot(index{1}, YMeasure{1});
title('Punkt P_1');
xlabel('Numer próbki'); ylabel('Amplituda drgañ');
subplot(5, 1, 2); plot(index{2}, YMeasure{2});
xlabel('Numer próbki'); ylabel('Amplituda drgañ');
title('Punkt P_2');
subplot(5, 1, 3); plot(index{3}, YMeasure{3});
xlabel('Numer próbki'); ylabel('Amplituda drgañ');
title('Punkt P_3');
subplot(5, 1, 4); plot(index{4}, YMeasure{4});
xlabel('Numer próbki'); ylabel('Amplituda drgañ');
title('Punkt P_4');
subplot(5, 1, 5); plot(index{5}, YMeasure{5});
xlabel('Numer próbki'); ylabel('Amplituda drgañ');
title('Punkt P_5');

%% Wyznaczenie maksimów fragmentów sygna³ów

YMeasurePeaksAll = cell(1, 5);
YMeasurePeaksIndecesAll = cell(1, 5);
YMeasurePeaks = cell(1, 5);
YMeasurePeaksIndeces = cell(1, 5);

for i = 1:1:5
    YMeasurePeaksAllLoop = [];
    YMeasurePeaksIndecesAllLoop = [];
    [YMeasurePeaksAll, YMeasurePeaksIndecesAll] = findpeaks(YMeasure{i});
    YMeasurePeaksLoop = [];
    YMeasurePeaksIndecesLoop = [];
    for j = 1:1:length(YMeasurePeaksAll)
        if YMeasurePeaksAll(j) > 0
            YMeasurePeaksLoop = [YMeasurePeaksLoop, YMeasurePeaksAll(j)];
            YMeasurePeaksIndecesLoop = [YMeasurePeaksIndecesLoop, j];
        end;
    end;
    YMeasurePeaks{i} = YMeasurePeaksLoop;
    YMeasurePeaksIndeces{i} = YMeasurePeaksIndecesLoop;
end;

%% Wyznaczanie logarytmicznego dekrementu t³umienia

decrement = cell(1, 5); % Macierz komórkowa dekrementu
decrementMean = zeros(1, 5); % Wektor œredniej dekrementu

for i = 1:1:5
    YMeasurePeaksLoop = YMeasurePeaks{i};
    decrementLoop = zeros(1, length(YMeasurePeaksLoop)-1);
    for l = 1:1:length(YMeasurePeaksLoop) - 1
        decrementLoop(l) = log(YMeasurePeaksLoop(l) ./ YMeasurePeaksLoop(l+1));
    end;
    decrement{i} = decrementLoop;
    decrementMean(i) = mean(decrementLoop);
end;


%% Wyznaczenie wspó³czynnika t³umienia

forkedTuneMass = 0.208; % Masa kamertonu
Tn = 1 ./ 438.0607; % Okres sygna³u kamertonu
coefficient = zeros(1, 5); % Wektor wspó³czynników

for i = 1:1:5
    coefficient(i) = (2 * decrementMean(i) * forkedTuneMass) ./ Tn;
end;

coefficientMean = mean(coefficient);

czas = YMeasurePeaksIndeces{1} ./ fs1;
wykres = 0.2 .* exp(- coefficientMean * czas) .* cos(2 * pi() * 438.0607 * czas);
figure(12); plot(czas, wykres);
