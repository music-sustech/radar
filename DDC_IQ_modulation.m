
clc
clear all

f_c = 2.4e9;
c = 3e8;
lambda = c/f_c;         %lambda
f_lowIF = 5e4;  %Low intermediate frequency

T = 100;
Fs = 5e5;         %sampling frequency
Ns = Fs*T;
%n = 0:Ns-1;
n = linspace(0,Ns,Ns);
t = 1/Fs .* n;

Delta_f = 1/T;      

A_heart = 1e-3;         %Amplitude of heart beats
f_heart = 1.2;
A_resp =  1e-2;        %Amplitude of respiration
f_resp = 0.25;

h_t = A_heart*sin(2*pi*f_heart*t);  %signal of heart beat
r_t = A_resp*sin(2*pi*f_resp*t);  %signal of respiration

IF_t = cos(pi/4+2*pi*f_lowIF*t+(h_t+r_t)*4*pi/lambda);

LO_I = sin(2*pi*f_lowIF*t);   % singal used to generate I channel signal
LO_Q = cos(2*pi*f_lowIF*t);   % signal used to generate Q channel signal (how about signal)

I_t = IF_t.*LO_I;
Q_t = IF_t.*LO_Q;

figure(1)
subplot(2,1,1)
plot(t(1:100),LO_I(1:100));
xlabel("Time /s");
title("LO of I&Q");

subplot(2,1,2)
plot(t(1:100),LO_Q(1:100));
xlabel("Time /s");


figure(2)
subplot(2,1,1)
plot(t(1:100),I_t(1:100));
xlabel("Time/s");
title("Raw signal in Channel I");

subplot(2,1,2)
plot(t(1:100),Q_t(1:100));
xlabel("Time/s");
title("Raw signal in Channel Q");

S_I_filter = lowpass(I_t, 10 , Fs);
S_Q_filter = lowpass(Q_t, 10 , Fs);

Phi_arctan = atan(S_I_filter./S_Q_filter);  %atan /rad    atand /degree

figure(3)
subplot(3,1,1)
plot(t,S_I_filter);
title("Signal in Channel I ")
xlabel("Time/s")


subplot(3,1,2)
plot(t,S_Q_filter);
title("Signal in Channel Q ")
xlabel("Time/s")

subplot(3,1,3)
plot(t, Phi_arctan);
title("Arctangent signal")
xlabel("Time/s") %2 ??


%spectrum domain
Phi_arctan_fft = abs(fft(Phi_arctan));
f_axis = n*1/T;

figure(4)
title('经过混频和滤波的反正切FFT信号')
plot(f_axis(1:200),Phi_arctan_fft(1:200));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S_I_contrast = sin(pi/4+(h_t+r_t)*4*pi/lambda);
S_Q_contrast = cos(pi/4+(h_t+r_t)*4*pi/lambda);
S_arct = atan(S_I_contrast./S_Q_contrast);
S_arct_fft = abs(fft(S_arct));

figure(5)
title('理想信号（未经混频和滤波）')
plot(f_axis(1:200),S_arct_fft(1:200));

I_t_fft = abs(fft(I_t));
Q_t_fft = abs(fft(Q_t));

figure(6)
title('FFT后的I/Q通道信号')
plot(f_axis(1:200),I_t_fft(1:200));
plot(f_axis(1:200),Q_t_fft(1:200));





