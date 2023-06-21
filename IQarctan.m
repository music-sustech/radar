clc;
clear all

f_c = 2.4e9;
c = physconst('Lightspeed');
lamda=c/f_c;
f_lowIF = 5e4;              %Low intermediate frequency

T = 100;
Fs = 4e5;                   %sampling frequency
Ns = Fs*T;
n = 0:Ns-1;
t = 1/Fs .* n;
f_axis = n*1/T;

Delta_f = 1/T;      

A_heart = 1e-3;             %Amplitude of heart beats
f_heart = 1.25;
A_resp =  1e-2;             %Amplitude of respiration
f_resp = 0.25;

h_t = A_heart*sin(2*pi*f_heart*t);  %signal of heart beat
r_t = A_resp*sin(2*pi*f_resp*t);  %signal of respiration

IF_t = cos(2*pi*f_lowIF.*t+(h_t+r_t)*4*pi/lamda);


%%  filter
LO_I = cos(2*pi*f_lowIF*t);
LO_Q = -sin(2*pi*f_lowIF*t);

I_t = IF_t.*LO_I;
Q_t = IF_t.*LO_Q;

LPF_I_t = lowpass(I_t, 10, Fs);
LPF_Q_t = lowpass(Q_t, 10, Fs);

%SUM = sum(LPF_I_t.*LPF_Q_t)

%% Arctangent demodulation 

Phi_arctan = atan2(LPF_I_t, LPF_Q_t);

%Phi_arctan = unwrap(Phi_arctan,pi/2);
% for n=1:length(Phi_arctan)-1
%     if Phi_arctan(n+1) - Phi_arctan(n) > pi/2
%         Phi_arctan(n+1) = Phi_arctan(n+1) - pi;
%     elseif Phi_arctan(n+1) - Phi_arctan(n) < -pi/2
%         Phi_arctan(n+1) = Phi_arctan(n+1) + pi;
%     end
% 
% end

for n=1:length(Phi_arctan)-1
    if Phi_arctan(1,n+1) - Phi_arctan(1,n) >= pi/2 
       Phi_arctan(1,n+1) = Phi_arctan(1,n+1) - pi;
    end
    if Phi_arctan(1,n+1) - Phi_arctan(1,n) < -pi/2 
        Phi_arctan(1,n+1) = Phi_arctan(1,n+1) + pi;
    end
end

Phi_arctan = detrend(Phi_arctan);

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

%%%%%%%%%%%%%%%%%%%%%%%%%% plot LO I(t) and LO Q(t) %%%%%%%%%%%%%%%%%%%%%%%
figure(2);
subplot(2,1,1);
%plot(t(1:200),LO_I(1:200),'*');
plot(t(1:200),LO_I(1:200),'-*');
xlabel("time (s)");
ylabel("LO I(t)");

subplot(2,1,2);
plot(t(1:200),LO_Q(1:200),'-*');
xlabel("time (s)");
ylabel("LO Q(t)");

%%%%%%%%%%%%%%%%%%%%%%%%%% plot IF(t), IF I(t) and IF Q(t) %%%%%%%%%%%%%%%%%%%%%%%
figure(3);
subplot(3,1,1);
%plot(t(1:200),LO_I(1:200),'*');
plot(t(1:200),IF_t(1:200),'-*');
xlabel("time (s)");
ylabel("IF(t)");

subplot(3,1,2);
%plot(t(1:2000),I_t(1:2000),'-*');
plot(t, I_t);
xlabel("time (s)");
ylabel("IF I(t)");

subplot(3,1,3);
%plot(t(1:2000),Q_t(1:2000),'-*');
plot(t,Q_t);
xlabel("time (s)");
ylabel("IF Q(t)");


%%%%%%%%%%%%%%%%%%%%%%%%%% plot IF I(t) and IF Q(t) after lowpass filtering %%%%%%%%%%%%%%%%%%%%%%%

figure(4);
subplot(2,1,1);
plot(t,LPF_I_t);
xlabel("time (s)");
ylabel("LPF IF I(t)");

subplot(2,1,2);
plot(t,LPF_Q_t);
xlabel("time (s)");
ylabel("LPF IF Q(t)");



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(5);
subplot(2,1,1);
plot(t,Phi_arctan);
xlabel("time (s)");
ylabel("Phase(t) (rad)");


subplot(2,1,2);
plot(t,Phi_arctan*lamda/(4*pi)*1000);   %%%%% use the unwrapped phase to extract h(t) and r(t)
xlabel("time (s)");
ylabel("Displacement(t) (mm)");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%For comparison, FFT of wrapped phi(t) is inserted in subplot of figure 6.

figure(6);
subplot(2,1,1);
plot(f_axis(1:200),Phi_arctan_fft(1:200));
xlabel("frequency (Hz)");
ylabel("FFT spectrum of wrapped phi(t)");

subplot(2,1,2);
plot(f_axis(1:200),Phi_arctan_fft(1:200));
xlabel("frequency (Hz)");
ylabel("FFT spectrum of unwrapped phi(t)");







