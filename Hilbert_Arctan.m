clc;
clf;
clear all

f_c = 2.4e9;
c = 3e8;
lamda=c/f_c;
f_lowIF = 5e4;  %Low intermediate frequency

T = 100;
Fs = 4e5;         %sampling frequency
Ns = Fs*T;
Delta_f = 1/T; 

n = 0:Ns-1;
t = 1/Fs .* n;
f_axis = n*1/T;

     

A_heart = 1e-3;         %Amplitude of heart beats
f_heart = 1.25;
A_resp =  1e-3;        %Amplitude of respiration
f_resp = 0.25;

h_t = A_heart*sin(2*pi*f_heart*t);  %signal of heart beat
r_t = A_resp*sin(2*pi*f_resp*t);  %signal of respiration

IF_t = cos(2*pi*f_lowIF*t+(h_t+r_t)*4*pi/lamda);

Complex_IF = hilbert(IF_t);
Complex_LO = cos(2*pi*f_lowIF*t)-1i*sin(2*pi*f_lowIF*t);
IF = Complex_IF.*Complex_LO;
I_t = real(IF);
Q_t = imag(IF);

Phi_arctan = atan2(I_t,Q_t);

for n=1:length(Phi_arctan)-1
    if Phi_arctan(1,n+1) - Phi_arctan(1,n) >= pi/2 
       Phi_arctan(1,n+1) = Phi_arctan(1,n+1) - pi;
    end
    if Phi_arctan(1,n+1) - Phi_arctan(1,n) < -pi/2 
        Phi_arctan(1,n+1) = Phi_arctan(1,n+1) + pi;
    end
end


Phi_arctan_fft = abs(fft(Phi_arctan));


%%%%%%%%%%%%%%%%%%%%%%%%%% plot h(t) and r(t) %%%%%%%%%%%%%%%%%%%%%%%
figure(1);
subplot(2,1,1);
plot(t,h_t);
xlabel("time (s)");
ylabel("heart h(t)");

subplot(2,1,2);
plot(t,r_t);
xlabel("time (s)");
ylabel("respiration r(t)");

%%%%%%%%%%%%%%%%%%%%%%%%%% plot IF(t), IF I(t) and IF Q(t) %%%%%%%%%%%%%%%%%%%%%%%
figure(2);
subplot(2,1,1);
plot(t,I_t);
xlabel("time (s)");
ylabel("IF I(t)");

subplot(2,1,2);
plot(t,Q_t);
xlabel("time (s)");
ylabel("IF Q(t)");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(3);
subplot(3,1,1);
plot(t,Phi_arctan);
xlabel("time (s)");
ylabel("Phase(t) (rad)");


subplot(3,1,2);
plot(t,Phi_arctan*lamda/(4*pi)*1000);   %%%%% use the unwrapped phase to extract h(t) and r(t)
xlabel("time (s)");
ylabel("Displacement(t) (mm)");

subplot(3,1,3)
plot(f_axis(1:200),Phi_arctan_fft(1:200));
xlabel("Frequency(Hz)");
ylabel("Spectrum of signal")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Q_ideal = sin(2*pi*t);
I_ideal = cos(2*pi*t);

figure(4)
plot(I_t,Q_t,'-*');
xlabel("I Channel");
ylabel("Q_channel");
title("constellation");
hold on
plot(I_ideal,Q_ideal);
hold off;







