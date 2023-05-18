

f_c = 2.4e9;
c = 3e8;
lambda = c/f_c;         %lambda
f_lowIF = 5e4;  %Low intermediate frequency

T = 100;
Fs = 8e5;
Ns = Fs*T;
n = 0:Ns-1;
t= n/Fs;

Delta_f = 1/T;
f_axis = n*1/T;

A_heart = 1e-3;         %Amplitude of heart beats
f_heart = 1.2;
A_resp =  1e-2;        %Amplitude of respiration
f_resp = 0.25;

h_t = A_heart*sin(2*pi*f_heart*t);  %signal of heart beat
r_t = A_resp*sin(2*pi*f_resp*t);  %signal of respiration

IF_t = cos(pi/2+2*pi*f_lowIF*t+(h_t+r_t)*4*pi/lambda);

%%%%%%%%%%%%%%%%%%  IQ modulation  %%%%%%%%%%%%%%%%%%%%%%%%

LO_I = -sin(2*pi*f_lowIF*t);   % singal used to generate I channel signal
LO_Q = cos(2*pi*f_lowIF*t);   % signal used to generate Q channel signal 

I_t = IF_t.*LO_I;
Q_t = IF_t.*LO_Q;

I_t_fft = abs(fft(I_t));
Q_t_fft = abs(fft(Q_t));

S_I_filter = lowpass(I_t, 10 , Fs);
S_Q_filter = lowpass(Q_t, 10 , Fs);


%%%%%%%%%%%%%%%%%%  MDACM demodulation %%%%%%%%%%%%%%%%%%%%%

Diff_MDACM = lambda/(4*pi)*(S_I_filter(1:Ns-1).*S_Q_filter(2:Ns)-S_I_filter(2:Ns).*S_Q_filter(1:Ns-1));    %atan /rad    atand /degree

x_MDACM = zeros(1,Ns-1);

x_MDACM(1) = Diff_MDACM(1);
for i = 2:length(Diff_MDACM)
    x_MDACM(i) = x_MDACM(i-1) + Diff_MDACM(i);   
end

x_MDACM_fft = abs(fft(x_MDACM));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%     PLOT        %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%% H_t & R_t s& IF signal %%%%%%%%%%%%%%%%%
figure(1)
subplot(3,1,1)
plot(t, h_t,'-*');
xlabel('Time(s)');
ylabel('Amplitude of Heart Beat Signal(m)');

subplot(3,1,2)
plot(t,r_t,'-*');
xlabel('Time(s)');
ylabel('Amplitude of Respiration Signal(m)');
subplot(3,1,3)
plot(t(1:100),IF_t(1:100),'-*');
xlabel('Time(s)');
ylabel('Amplitude of Low-IF Signal(m)');

%%%%%%%%%%%%%%%%  LO of I&Q      %%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
subplot(2,1,1)
plot(t(1:100),LO_I(1:100),'-*');
xlabel("Time(s)");
ylabel("LO value of I");

subplot(2,1,2)
plot(t(1:100),LO_Q(1:100),'-*');
xlabel("Time(s)");
ylabel("LO value of Q");


%%%%%%%%%%%%%%% Raw signal of I&Q after mixer %%%%%%%%%%%%%%%%%%%%%%%%%

figure(3)
subplot(2,1,1)
plot(t(1:100),I_t(1:100));
xlabel("Time(s)");
ylabel("Raw signal in Channel I");


subplot(2,1,2)
plot(t(1:100),Q_t(1:100));
xlabel("Time(s)");
ylabel("Raw signal in Channel Q");

%%%%%%%%%%%%%%%  Signal after  filter %%%%%%%%%%%%%%%%
figure(4)
subplot(2,1,1)
plot(t(1:100),S_I_filter(1:100));
xlabel("Time(s)");
ylabel("Signal in Channel I");


subplot(2,1,2)
plot(t(1:100),S_Q_filter(1:100));
xlabel("Time(s)");
ylabel("Signal in Channel Q ");


%%%%%%%%%%%%%%%  demodulation signal %%%%%%%%%%%%%%%%%%%%%%
figure(5)
plot(t(2:Ns), x_MDACM);
xlabel("Time(s)");
ylabel("Displacement after MDACM demodulation(m)");


figure(6)
plot(f_axis(1:200), x_MDACM_fft(1:200));
title("MDACM signal after FFT (respiration&heart signal)");
xlabel("Frequency/Hz");




%%%%%%%%%%%%%%%%% Constellation diagram %%%%%%%%%%%%%%%%%
alpha = 0:pi/40:2*pi;
r = 0.5;
x = r*cos(alpha);
y = r*sin(alpha);

figure(7)
plot(S_I_filter,S_Q_filter);
xlabel("I(t)");
ylabel("Q(t)");
axis([-1,1,-1,1]);
hold on
plot(x,y,'--');

















