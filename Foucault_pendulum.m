function Foucault_pendulum
clear; clc;                            % initialization
figure_init('Foucault Pendulum');      % create and maximize a figure window
cmap = colormap('cool');               % colors to be used for plots
w_e = pi/43080;                        % rotational speed of the earth (rad/s)
g = 9.81;                              % acceleration due to gravity (m/s^2)
l = 60;                                % length of pendulum (m)
O = sqrt(g/l);                         % omega (rad/s)
x0 = 0.2; y0 = 0.1; xp0 = 0; yp0 = 0;  % initial conditions (m, m/s)
IC = [x0 y0 xp0 yp0];                  % initial condition vector
tspan = 0:(192*60-1);                  % simulate for 192 minutes
lambda = 0;                            % initial lambda
hstat = create_stat('');               % create object for status text
while lambda <= 90                     % solve through lambda = 90°
    plot_setup(lambda);                % init plot for this lambda
    update_stat(hstat,sprintf('Calculating for \\lambda = %u^o',lambda'));    drawnow;
    [t, sol] = ode45(@problem_setup,tspan,IC,[],w_e,O,lambda);
    for i = 1:64  % loop used to plot every three minutes a different color
        plot(sol(180*i-179:180*i,1),...% plot x versus y
            sol(180*i-179:180*i,2),...
            'linewidth',2,'color',...
            cmap(i,:))
        update_stat(hstat,sprintf('Plotting \\lambda =%u^o, t=%u',lambda,i*3));
    end
    if lambda == 0                     % place a text box telling user what
        % colors of plot mean
        st = ['Initital motion represented ',...
            'by cyan\nMotion ',...
            'after 192 minutes represented ',...
            'by magenta'];
        st = sprintf(st);
        text(0.03,-0.06,...
            st,'horizontalalignment','center',...
            'fontname','times','fontsize',14,...
            'backgroundcolor','w')
    end
    lambda = lambda + 30;              % increment lambda
end
update_stat(hstat,'Foucault Pendulum Results');
return
 
function primes = problem_setup(~,sol,w_e,O,lambda)
% The dynamic model is a system of two second order differential equations.
% Matlab is only capable of solving systems of first order differential
% equations; therefore, the problem must be broken down into four first
% order differential equations.
%
% x1(t) = x(t)
% x2(t) = x'(t) = x1'(t)
% x2'(t) = x''(t)
% y1(t) = y(t)
% y2(t) = y'(t) = y1'(t)
% y2'(t) = y''(t)
%
% x1'(t) = x2(t)
% x2'(t) = 2*P*y2(t)-O^2*x1(t)
% y1'(t) = y2(t)
% y2'(t) = -2*P*x2(t) - O^2*y1(t)
%
% indexing each created variable out of sol vector to make equations easier
% to read
x1 = sol(1);
y1 = sol(2);
x2 = sol(3);
y2 = sol(4);
P = w_e*sind(lambda);
% defining the four first order differential equations
x1p = x2;
x2p = 2*P*y2-O^2*x1;
y1p = y2;
y2p = -2*P*x2-O^2*y1;
primes = [x1p; y1p; x2p; y2p];  % formatting output in column vector
return
 
function figure_init(txt)
% use java interface to maximize a figure window
close all;
figure(1);
set(gcf,'name',txt);
drawnow; % needed to get figure displayed
jFrame = get(handle(gcf),'javaframe');
jFrame.setMaximized(true);
drawnow;
return
 
function plot_setup(lambda)
% determine subplot and add titles and labels
subplot(2,2,lambda/30+1)           % subplot for each lambda
title(['\lambda = ' num2str(lambda) '°'],...
    'fontname','times','fontweight',...
    'bold','fontsize',16)
xlabel ('x(t) [meters]','fontname',...
    'times','fontweight','bold',...
    'fontsize',14)
ylabel ('y(t) [meters]','fontname',...
    'times','fontweight','bold',...
    'fontsize',14)
hold on;
grid on
drawnow;
return
 
function update_stat(hstat,txt)
set(hstat,'string',txt);
drawnow;
return
 
function h=create_stat(txt)
% create annotation object for status text
h=annotation('textbox',[.4 .45 .2 .1],...
    'fontsize',16,...
    'horizontalalign','center',...
    'verticalalign','middle',...
    'fitboxtotext','on',...
    'string',txt);
drawnow;
return