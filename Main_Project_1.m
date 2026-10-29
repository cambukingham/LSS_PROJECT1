%% Industrial Monitoring Project
% Main script
clear; 
clc; 
close all;
%% ================================================================
%  Load and display the industrial environment
% ================================================================
env  = factoryEnvironment();
hEnv = gcf;                       % handle of the factory figure

%% ================================================================
%  PART 1: ROBOT TRAJECTORY DESIGN
% ================================================================
rRobot = 0.40;                    % robot radius [m]
vmax   = 1.0;                     % max speed [m/s]
vcmd   = 1.0;                     % commanded speed on every leg [m/s]
Tsens  = 55;                      % sensing time per stop [s]
%  Justification: Tsens >= t90 = tau*ln(10) = 50.7 s (Problem 4(v))
%  and 62.6 + 4*Tsens < 300.5 s (battery limit)  ->  Tsens < 59.5 s.

q0 = 1; qcrit = 0.60; lambda = 1.7e-3;

% Waypoints (rows are [x y]); legs are straight lines between them
wp = [ 2   2;      % 1: point A
       2   12;     % 2: stop 1
       13  12;     % 3: stop 2
       16.5 3.25;  % 4: stop 3
       25  9.2;    % 5: NOT A STOP, CONSIDER THIS A GO
       25  18;     % 6: stop 4
       38  18 ];   % 7: point B
stopAt = [2 3 4 6];               % waypoints where the robot stops

nLeg   = size(wp,1) - 1;
tStart = zeros(nLeg,1);  tEnd = zeros(nLeg,1);  vel = zeros(nLeg,2);
stopStart = zeros(1,4);  stopEnd = zeros(1,4);
tcur = 0;  ns = 0;
for k = 1:nLeg
    d   = wp(k+1,:) - wp(k,:);
    dur = norm(d)/vcmd;
    tStart(k) = tcur;  tEnd(k) = tcur + dur;
    vel(k,:)  = d/dur;                      % constant velocity on leg k
    tcur      = tEnd(k);
    if ismember(k+1, stopAt)                % stationary interval
        ns = ns + 1;
        stopStart(ns) = tcur;  stopEnd(ns) = tcur + Tsens;
        tcur = tcur + Tsens;
    end
end
Tmission = tcur;
Ttravel  = Tmission - 4*Tsens;

% Build x(t), y(t) as sums of shifted ramps (slope = leg velocity)
dt = 0.01;
t  = 0:dt:Tmission;
x  = wp(1,1)*ones(size(t));
y  = wp(1,2)*ones(size(t));
for k = 1:nLeg
    x = x + rampFunction(t, tStart(k), tEnd(k), vel(k,1));
    y = y + rampFunction(t, tStart(k), tEnd(k), vel(k,2));
end

% Print the analytic expressions
fprintf('x(t) = %g', wp(1,1));
for k = 1:nLeg
    if abs(vel(k,1)) > 1e-12
        fprintf('\n     %+.6f [r(t-%.5f) - r(t-%.5f)]', vel(k,1), tStart(k), tEnd(k));
    end
end
fprintf('\n\ny(t) = %g', wp(1,2));
for k = 1:nLeg
    if abs(vel(k,2)) > 1e-12
        fprintf('\n     %+.6f [r(t-%.5f) - r(t-%.5f)]', vel(k,2), tStart(k), tEnd(k));
    end
end
fprintf('\n(r(t) = t*u(t) is the unit ramp)\n\n');

% Speed from the known (piecewise-constant) leg velocities
xdot = zeros(size(t));  ydot = zeros(size(t));
for k = 1:nLeg
    idx = (t >= tStart(k)) & (t < tEnd(k));
    xdot(idx) = vel(k,1);
    ydot(idx) = vel(k,2);
end
speed = sqrt(xdot.^2 + ydot.^2);

% Collision / boundary check (clearance should be >= 0)
clr = inf(size(t));
for k = 1:size(env.circles,1)
    c = env.circles(k,:);
    clr = min(clr, hypot(x-c(1), y-c(2)) - c(3) - rRobot);
end
for k = 1:size(env.rectangles,1)
    r  = env.rectangles(k,:);
    ddx = max(max(r(1)-x, 0), x-r(2));
    ddy = max(max(r(3)-y, 0), y-r(4));
    clr = min(clr, hypot(ddx,ddy) - rRobot);
end
clr = min(clr, min([x-rRobot; 40-rRobot-x; y-rRobot; 20-rRobot-y],[],1));
fprintf('Min clearance to obstacles/walls : %.3f m (must be >= 0)\n', min(clr));
fprintf('Max speed                        : %.4f m/s (vmax = %g)\n', max(speed), vmax);

% Battery
qEnd  = q0*exp(-lambda*Tmission);
tCrit = -log(qcrit/q0)/lambda;
fprintf('Ttravel  = %.4f s\nTsensing = %.1f s (x4 = %.1f s)\nTmission = %.4f s\n', ...
        Ttravel, Tsens, 4*Tsens, Tmission);
fprintf('q(Tmission) = %.4f  (critical %.2f, reached at t = %.1f s)\n', qEnd, qcrit, tCrit);
fprintf('Battery constraint satisfied: %d\n\n', qEnd > qcrit);
for i = 1:4
    fprintf('Monitoring location %d: (%.2f, %.2f), t = %.2f to %.2f s\n', ...
        i, wp(stopAt(i),1), wp(stopAt(i),2), stopStart(i), stopEnd(i));
end

% Trajectory on the factory map
figure(hEnv); hold on;
plot(x, y, 'b', 'LineWidth', 2);
plot(wp(stopAt,1), wp(stopAt,2), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
for i = 1:4
    text(wp(stopAt(i),1)+0.4, wp(stopAt(i),2)+0.6, sprintf('S%d',i), 'FontSize', 12, 'Color', 'r');
end

% x(t), y(t)
figure('Color','w');
subplot(2,1,1); plot(t, x, 'LineWidth', 1.8); grid on; ylabel('x(t) [m]');
title('Robot position signals');
subplot(2,1,2); plot(t, y, 'LineWidth', 1.8); grid on; ylabel('y(t) [m]'); xlabel('t [s]');

% Speed
figure('Color','w');
plot(t, speed, 'LineWidth', 1.8); hold on;
yline(vmax, 'r--', 'v_{max}', 'LineWidth', 1.5);
grid on; xlabel('t [s]'); ylabel('v(t) [m/s]'); title('Robot speed'); ylim([0 1.3]);

%% ================================================================
%  PART 2: VOC SENSOR
% ================================================================
A = 8.0e4;  alpha = 0.602;
VC = 5;     RL = 10e3;
tau = 22;

%% ---------------- Problem 2: static characteristic ----------------
C = linspace(1, 100, 1000);
Rinf = A*C.^(-alpha);

figure('Color','w');
plot(C, Rinf/1e3, 'LineWidth', 2); grid on;
xlabel('C [ppm]'); ylabel('R_\infty [k\Omega]');
title('Problem 2: R_\infty vs C (linear axes)');

figure('Color','w');
loglog(C, Rinf/1e3, 'LineWidth', 2); grid on;
xlabel('C [ppm]'); ylabel('R_\infty [k\Omega]');
title('Problem 2: R_\infty vs C (log axes)');
%% ---------------- Problem 3: voltage divider ----------------------
% VOUT(C) = VC*RL/(A*C^-alpha + RL)
VoutC = VC*RL ./ (Rinf + RL);
figure('Color','w');
plot(C, VoutC, 'LineWidth', 2); grid on;
xlabel('C [ppm]'); ylabel('V_{OUT} [V]');
title('Problem 3: V_{OUT} vs C');   % clearly nonlinear
% Inverse:  RS = RL*(VC/VOUT - 1)
%           C  = (RS/A)^(-1/alpha) = (A/RS)^(1/alpha)

%% ---------------- Problem 4: dynamic response ---------------------
% (i)  LTI, causal, BIBO stable (pole at s = -1/tau, h(t) absolutely integrable)
tt = 0:0.01:100;
step_resp = 1 - exp(-tt/tau);                 % (ii)
h_resp    = (1/tau)*exp(-tt/tau);             % (iii) h(t) = ds/dt
figure('Color','w');
plot(tt, step_resp, 'LineWidth', 2); grid on;
xlabel('t [s]'); ylabel('R_S(t)'); title('Problem 4(ii): unit-step response');
figure('Color','w');
plot(tt, h_resp, 'LineWidth', 2); grid on;
xlabel('t [s]'); ylabel('h(t)'); title('Problem 4(iii): impulse response');

% (iv) convolution check
dtc = 0.01;
s_conv = conv(h_resp, ones(size(tt)))*dtc;
s_conv = s_conv(1:numel(tt));
fprintf('\nMax |step - h*u| = %.2e\n', max(abs(s_conv - step_resp)));

% (v) t90
t90 = tau*log(10);
fprintf('t90 = tau*ln(10) = %.2f s\n', t90);

% (vi) 5 ppm -> 50 ppm
Rinf1 = A*5^(-alpha);   Rinf2 = A*50^(-alpha);
fprintf('Rinf1 = %.1f ohm, Rinf2 = %.1f ohm\n', Rinf1, Rinf2);
Rs   = Rinf2 + (Rinf1 - Rinf2)*exp(-tt/tau);
Vout = VC*RL ./ (Rs + RL);
figure('Color','w');
subplot(2,1,1); plot(tt, Rs/1e3, 'LineWidth', 2); grid on;
ylabel('R_S(t) [k\Omega]'); title('Problem 4(vi): response to 5 \rightarrow 50 ppm step');
subplot(2,1,2); plot(tt, Vout, 'LineWidth', 2); grid on;
ylabel('V_{OUT}(t) [V]'); xlabel('t [s]');

%% ---------------- Problem 5: sampling and quantization ------------
Vref = 5;  fs = 10;  Tsamp = 1/fs;
Nbits = [8 10 12];
n  = 0:round(100*fs);                 % samples over 0 to 100 s
tn = n*Tsamp;
RsN   = Rinf2 + (Rinf1 - Rinf2)*exp(-tn/tau);
VoutN = VC*RL ./ (RsN + RL);          % V_OUT[n]

% Full-scale view
figure('Color','w');
for m = 1:3
    N  = Nbits(m);
    L  = 2^N;  dV = Vref/L;
    fprintf('N = %2d bits: L = %4d levels, dV = %.5f V\n', N, L, dV);   % (i)
    VQ = midpointQuantizer(VoutN, N, Vref);                              % (iii)
    subplot(3,1,m);
    plot(tt, Vout, 'k', 'LineWidth', 1.2); hold on;
    stem(tn(1:10:end), VoutN(1:10:end), 'b', 'MarkerSize', 3);
    stairs(tn, VQ, 'r', 'LineWidth', 1);
    grid on; ylabel('V [V]');
    title(sprintf('N = %d bits', N));
    if m == 1, legend('V_{OUT}(t)','V_{OUT}[n]','V_Q[n]','Location','southeast'); end
end
xlabel('t [s]');

% Zoomed view (0-10 s) to make the staircases visible
figure('Color','w');
tz = tn <= 10;  ttz = tt <= 10;
for m = 1:3
    VQ = midpointQuantizer(VoutN, Nbits(m), Vref);
    subplot(3,1,m);
    plot(tt(ttz), Vout(ttz), 'k', 'LineWidth', 1.2); hold on;
    plot(tn(tz), VoutN(tz), 'b.', 'MarkerSize', 8);
    stairs(tn(tz), VQ(tz), 'r', 'LineWidth', 1.2);
    grid on; ylabel('V [V]');
    title(sprintf('N = %d bits (zoom, 0-10 s)', Nbits(m)));
    if m == 1, legend('V_{OUT}(t)','V_{OUT}[n]','V_Q[n]','Location','southeast'); end
end
xlabel('t [s]');

% (v)-(vi) steady-state reconstruction error
Css = linspace(1, 100, 2000);
VoutSS = VC*RL ./ (A*Css.^(-alpha) + RL);
figure('Color','w'); hold on;
maxErr = zeros(1,3);
for m = 1:3
    N   = Nbits(m);
    VQs = midpointQuantizer(VoutSS, N, Vref);
    Rhat = RL*(VC./VQs - 1);
    Chat = (A./Rhat).^(1/alpha);
    eC   = abs(Chat - Css)./Css*100;
    maxErr(m) = max(eC);
    plot(Css, eC, 'LineWidth', 1.3);
    fprintf('N = %2d: max error = %.3f %%, mean error = %.3f %%\n', N, max(eC), mean(eC));
end
grid on; xlabel('C [ppm]'); ylabel('e_C [%]');
title('Problem 5(vi): concentration reconstruction error');
legend('N = 8','N = 10','N = 12');
% (vii) Error is NOT uniform

%% ================================================================
%  Local functions
% ================================================================
function ramp = rampFunction(t, start_time, end_time, amplitude)
% Finite ramp: slope = amplitude between start_time and end_time, then holds
    ramp = amplitude .* ((t - start_time).*(t >= start_time) ...
                       - (t - end_time).*(t >= end_time));
end

function VQ = midpointQuantizer(V, N, Vref)
% Uniform midpoint quantizer with saturation at the top level
    dV = Vref/2^N;
    k  = floor(V/dV);
    k  = min(max(k, 0), 2^N - 1);
    VQ = (k + 0.5)*dV;
end