%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Change real singal to complex signal with Hilbert Transform and avoid using low pass filter.%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Radar Parameter

clc
clear
close all
f_c = 2.4e9;
c = 3e8;
lambda=c/f_c;
f_lowIF = 5e4;  %Low intermediate frequency

T = 100;
Fs = 4e5;         %sampling frequency
Ns = Fs*T;
n = 0:Ns-1;
t = n./Fs;
f = n./T;

Delta_f = 1/T;      

A_heart = 1e-3;         %Amplitude of heart beats
f_heart = 1.25;
A_resp =  1e-2;        %Amplitude of respiration
f_resp = 0.25;

h_t = A_heart*sin(2*pi*f_heart*t);  %signal of heart beat
r_t = A_resp*sin(2*pi*f_resp*t);  %signal of respiration

IF_t = cos(pi/2+2*pi*f_lowIF*t+(h_t+r_t)*4*pi/lambda);

Complex_IF = hilbert(IF_t);
fft_Complex_IF = abs(fft(Complex_IF));

Complex_LO = cos(2*pi*(f_lowIF)*t)+1i*sin(2*pi*(f_lowIF)*t);
fft_Complex_LO = abs(fft(Complex_LO));
IF = Complex_IF./Complex_LO;

S_I = real(IF);
S_Q = imag(IF);


%% MDACM Algorithm testing


Diff_MDACM = lambda/(4*pi)*(S_I(1:Ns-1).*S_Q(2:Ns)-S_I(2:Ns).*S_Q(1:Ns-1));    %atan /rad    atand /degree

x_MDACM(1) = Diff_MDACM(1);
for i = 2:length(Diff_MDACM)
    x_MDACM(i) = x_MDACM(i-1) + Diff_MDACM(i);   
end

x_MDACM_fft = abs(fft(x_MDACM));

%%%%%%%%%%%%%%%  demodulation signal %%%%%%%%%%%%%%%%%%%%%%
figure(1)
subplot(2,1,1)
plot(Diff_MDACM);
xlabel("Time(s)");
ylabel("Difference");
subplot(2,1,2)
plot(x_MDACM);
xlabel("Time(s)");
ylabel("Displacement after MDACM demodulation(m)");


figure(2)
plot(f(1:200), x_MDACM_fft(1:200));
title("MDACM signal after FFT (respiration&heart signal)");
xlabel("Frequency/Hz");
