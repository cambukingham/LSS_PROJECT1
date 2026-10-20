%% Industrial Monitoring Project
% Main script
clear;
clc;
close all; 
%% ================================================================
% Load and display the industrial environment
% ================================================================
env = factoryEnvironment();

%%%%


function step = stepFunction(lower_bound, upper_bound, amplitude, shift)

    t = lower_bound:0.01:upper_bound;
    
    % Create unit step using logical condition
    unitstep = (t >= shift);
    
    % Plot the step function
    plot(t, amplitude*unitstep, 'LineWidth', 2);
    grid on;
    %%%%

    
end

%test step
stepFunction(-20, 20, 5, 3)

%IS THIS WORKING



function ramp = rampFunction(lower_bound, upper_bound, amplitude, shift)
    
    % Define the time vector
    t = lower_bound:0.01:upper_bound;
    
    % Create unit step and multiply by t to get ramp
    unitstep = (t >= shift);
    ramp = t .* unitstep;
    
    % Plot the ramp function
    plot(t, amplitude * ramp, 'LineWidth', 2);
    grid on;
end


%test ramp
rampFunction(-20, 20, 5, 0)
