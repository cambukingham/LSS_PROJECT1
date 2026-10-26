%% Industrial Monitoring Project
% Main script
clear;
clc;
close all; 
%% ================================================================
% Load and display the industrial environment
% ================================================================
env = factoryEnvironment(); %loading the factory environment

%%%%


function step = stepFunction(lower_bound, upper_bound, amplitude, shift, y_offset)

    % Define the time vector
    t = lower_bound:0.01:upper_bound; %domain of the function

    % Create unit step using logical condition
    unitstep = (t >= shift);  

    % Calculate the step function with y offset
    step = y_offset + amplitude * unitstep; 

    % Plot the step function
    plot(t, step, 'LineWidth', 2);
    grid on;
end

%test step
%stepFunction(-20, 20, 5, 3)

%IS THIS WORKING



function ramp = rampFunction(lower_bound, upper_bound, amplitude, shift, y_start)

    % Define the time vector
    t = lower_bound:0.01:upper_bound;

    % Create a shifted ramp function
    ramp = amplitude .* (t - shift) .* (t >= shift) + y_start;

    % Plot the ramp function
    plot(t, ramp, 'LineWidth', 2);
    grid on;
end


%test ramp
%rampFunction(-20, 20, 5, 0)

stepFunction(1.999, 13, 10, 2, 2)
rampFunction(13, 16.5, -2.5, 13, 12)
rampFunction(16.5, 25, .7, 16.5, 3.25)
stepFunction(24.999, 38, 8.8, 25, 9.2)

%%JERRY's WORK%%

%xdot = gradient(x,t);
%ydot = gradient(y,t);

%speed = sqrt(xdot.^2 + ydot.^2);
%maxSpeed = max(speed);
%fprintf('Maximum speed: %.3f m/s\n', maxSpeed);


%%%%%%%%%% CHARGE EQUATION %%%%%%%%%%%

% Define constants
q0 = 1;                 
qcrit = 0.60;
lambda = 1.7e-3;        



% Define time vector (e.g., 0 to 3000 seconds)
t = linspace(0, 3000, 1000); 

% Calculate q(t)
q_t = q0 * exp(-lambda * t);





%%%%%%%%%%%%%%%%%%%% PART 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%
%given variables + equations:

A = 8e4;
alpha = .602;
concentration = 0:1:120;

r_inf = A*concentration.^(-alpha);

%graph of R_inf vs C, linear axis

figure;

grid on;

plot(concentration, r_inf, 'LineWidth', 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%graph of R_inf vs C, logarithmic axis
figure;
grid on;


logc = log(concentration);
log_r = log(A) - alpha*log(concentration); 

plot(logc, log_r, 'LineWidth', 2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% V_out plot %%%%%%%%%%%%%%%%%%%%%%



figure;
grid on;


v_out = 5 * (10e3 ./ (r_inf + 10e3));

plot(concentration, v_out, 'LineWidth', 2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%% sampling and quantization stages%%%%%%%%%%%%%%%%%%%%%%

%(i)
% number of available quantization levels: L = 2^N

v_ref = 5;
N1=8; 
N2=10; 
N3=12; 

L1 = 2^N1;
L2 = 2^N1;
L3 = 2^N3;

% voltage resolution/voltage step: V_delta = V_ref / L

v_delta1 = v_ref / L1;
v_delta2 = v_ref / L2;
v_delta3 = v_ref / L3;


%Sample signal Vout
%(ii)

