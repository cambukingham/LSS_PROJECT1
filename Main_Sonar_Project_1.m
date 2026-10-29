clear; clc; close all;
% Obtain transmitted and measured sonar signals
[s,r,fs] = sonarMeasurement();
% Time vectors
ts = (0:length(s)-1)/fs;
tr = (0:length(r)-1)/fs;
% Plot transmitted signal
figure;
plot(ts*1e3,s,'LineWidth',1.2)
grid on
xlabel('Time [ms]')
ylabel('Amplitude')
title('Transmitted Signal $s[n]$','Interpreter','latex')
% Plot received signal
figure;
plot(tr*1e3,r,'LineWidth',1.0)
grid on
xlabel('Time [ms]')
ylabel('Amplitude')
title('Measured Received Signal $r[n]$','Interpreter','latex')
% Cross-correlation
[cross_cor, lags] = xcorr(r, s);

% Keep only nonnegative lags
idx = lags >= 0;
lags = lags(idx);
cross_cor = cross_cor(idx);

% Plot magnitude of cross-correlation
figure;
plot(lags, abs(cross_cor), 'LineWidth', 1.0);
grid on;
xlabel('Lag (samples)');
ylabel('Magnitude of Cross-Correlation');
title('Cross-Correlation for Nonnegative Lags');
%-641 , 19.5429
%-1401, 8.6192
N1 = -1401;
N2 = -641;

d1 = (343 * N1) /(2*fs);
d2 = (343 * N2) /(2*fs);

disp(d1);
disp(d2);

%%D1= -2.4027 
% D2= -1.0993 in distance
