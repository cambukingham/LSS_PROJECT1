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
