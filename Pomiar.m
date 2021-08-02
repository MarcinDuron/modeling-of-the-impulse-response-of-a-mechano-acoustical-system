clc; clear all; close all;

% Niniejszy skrypt pozwala na realizacj� analizy widmowej
% zrealizowanych sygbna��w oraz wyznaczenie ich
% wykres�w w dziedzinie czasu i cz�stotliwo�ci

%% Wczytywanie danych sygna�u z pliku .wav

[y1, fs1] = audioread('Pomiar_Gora.wav');
[y2, fs2] = audioread('Pomiar_Przod.wav');
[y3, fs3] = audioread('Pomiar_Tyl.wav');
[y4, fs4] = audioread('Pomiar_Lewo.wav');
[y5, fs5] = audioread('Pomiar_Prawo.wav');
FS = [fs1 fs2 fs3 fs4 fs5]; % Wektor cz�st. pr�bkowania
Y = cell(1, 5); % Macierz kom�rkowa sygna��w
Y{1} = y1; Y{2} = y2; Y{3} = y3;
Y{4} = y4; Y{5} = y5;

%% Wyznaczenie dziedziny czasu

n1 = 776347; n2 = 874267; n3 = 698907;
n4 = 764827; n5 = 739227;
N = [n1 n2 n3 n4 n5]; % Wektor liczby pr�bek
tp = 0; % Czas rozpocz�cia pomiaru
T = cell(1, 5); % Macierz kom�rkowa czasu

for i = 1:1:5
    krok = 1 / FS(i); % Krok czasowy
    tk = (N(i) - 1) / FS(i); % Czas zako�czenia pomiaru
    t = tp:krok:tk; t = t'; % Wektor czasu
    T{i} = t;
end;

%% Wyznaczenie widma sygna�u

F = cell(1, 5); % Macierz kom�rkowa cz�stotliwo�ci
WIDMO = cell(1, 5); % Macierz kom�rkowa widm sygna�u

for j = 1:1:5
    n = N(j); y = Y{j}; fs = FS(j);
    yFFT = fft(y(1:n)); % Szybka transformata Fouriera
    f = fs * (0:n/2-1) / n; % Dziedzina cz�stotliwo�ci
    f = f';
    widmo = abs(yFFT / (n/2)); % Widmo amplitudowe sygna�u
    widmo = widmo(1:length(y)/2);
    F{j} = f;
    WIDMO{j} = widmo;
end;

%% Wizualizacja sygna�u w dziedzinie czasu i cz�stotliwo�ci

for k = 1:1:5
    t = T{k}; y = Y{k}; f = F{k}; widmo = WIDMO{k};
    figure(k); subplot(2, 1, 1); plot(t, y); grid on; hold on;
    xlabel('Czas t [s]'); ylabel('Amplituda drga�');
    subplot(2, 1, 2); plot(f, widmo); grid on; hold on;
    xlabel('Cz�stotliwo�� [Hz]'); ylabel('Widmo amplitudowe');
end;

%% Wyznaczenie cz�stotliwo�ci sygna��w

fModal = []; % Wektor cz�sto�ci
indeces = []; % Wektor indeks�w

for l = 1:1:5
    F{l} = f; WIDMO{l} = widmo;
    [maximum, index] = max(widmo);
    indeces = [indeces, index];
    fModal = [fModal, f(index)];
end;

%% Wyznaczenie b��du wzgl�dnego

fSignal = mean(fModal);
fIdeal = 440;
error = (abs(fSignal - fIdeal)) ./ fIdeal * 100;
