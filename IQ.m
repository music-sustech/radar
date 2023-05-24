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
n = 0:Ns-1;
t = 1/Fs .* n;

Delta_f = 1/T;      

A_heart = 1e-3;         %Amplitude of heart beats
f_heart = 1.2;
A_resp =  1e-2;        %Amplitude of respiration
f_resp = 0.25;

h_t = A_heart*sin(2*pi*f_heart*t);  %signal of heart beat
r_t = A_resp*sin(2*pi*f_resp*t);  %signal of respiration

IF_t = cos(pi/2+2*pi*f_lowIF*t+(h_t+r_t)*4*pi/lamda);

%IQ modulation

LO_I = sin(2*pi*f_lowIF*t);   % singal used to generate I channel signal
LO_Q = cos(2*pi*f_lowIF*t);   % signal used to generate Q channel signal 

I_t = IF_t.*LO_I;
Q_t = IF_t.*LO_Q;

%%%%%%%%%%%%%%%%%%%%%%%%%% plot h(t) and r(t) %%%%%%%%%%%%%%%%%%%%%%%
figure(1);
subplot(2,1,1);
plot(t,h_t);
xlabel("time (s)");
ylabel("heart signal");

subplot(2,1,2);
plot(t,r_t);
xlabel("time (s)");
ylabel("respiration signal");

%%%%%%%%%%%%%%%%%%%%%%%%%% plot LO I(t) and LO Q(t) %%%%%%%%%%%%%%%%%%%%%%%
figure(2);
subplot(2,1,1);
%plot(t(1:200),LO_I(1:200),'*');
plot(t(1:200),LO_I(1:200),'-*');
xlabel("time (s)");
ylabel("LO I signal");

subplot(2,1,2);
plot(t(1:200),LO_Q(1:200),'-*');
xlabel("time (s)");
ylabel("LO Q signal");

%%%%%%%%%%%%%%%%%%%%%%%%%% plot IF(t), IF I(t) and IF Q(t) %%%%%%%%%%%%%%%%%%%%%%%
figure(3);
subplot(3,1,1);
%plot(t(1:200),LO_I(1:200),'*');
plot(t(1:200),IF_t(1:200),'-*');
xlabel("time (s)");
ylabel("IF(t) signal");

subplot(3,1,2);
plot(t(1:200),I_t(1:200),'-*');
xlabel("time (s)");
ylabel("IF I signal");

subplot(3,1,3);
plot(t(1:200),Q_t(1:200),'-*');
xlabel("time (s)");
ylabel("IF Q signal");


%%%%%%%%%%%%%%%%%%%%%%%%%% plot IF(t), IF I(t) and IF Q(t) %%%%%%%%%%%%%%%%%%%%%%%

LPF_I_t = lowpass(I_t, 10 , Fs);
LPF_Q_t = lowpass(Q_t, 10 , Fs);

figure(4);
subplot(2,1,1);
%plot(t(1:200),LO_I(1:200),'*');
plot(t,LPF_I_t);
xlabel("time (s)");
ylabel("LPF IF I(t) signal");

subplot(2,1,2);
plot(t,LPF_Q_t);
xlabel("time (s)");
ylabel("LPF IF Q(t) signal");


%%%%%%%%%%%%%%%%%%%%%%%%%% plot phi(t) and displacement(t) %%%%%%%%%%%%%%%%%%%%%%%

Phi_arctan = atan(LPF_I_t./LPF_Q_t);  %%%%%% atan unit: rad;  atand unit: degree.
figure(5);
subplot(3,1,1);
%plot(t(1:200),LO_I(1:200),'*');
plot(t,Phi_arctan);
xlabel("time (s)");
ylabel("Phase(t) (rad)");

subplot(3,1,2);
%plot(t(1:200),LO_I(1:200),'*');

for n=1:length(Phi_arctan)-1
    if Phi_arctan(1,n+1) - Phi_arctan(1,n) > pi/2 
       Phi_arctan(1,n+1) = Phi_arctan(1,n+1) - pi;
    end
    if Phi_arctan(1,n+1) - Phi_arctan(1,n) < -pi/2 
        Phi_arctan(1,n+1) = Phi_arctan(1,n+1) + pi;
    end
end


plot(t,Phi_arctan);     %%%%%% unwrap phase by Yuheng Cao
xlabel("time (s)");
ylabel("Unwrapped Phase(t) (rad)");

subplot(3,1,3);
plot(t,Phi_arctan*lamda/(4*pi)*1000);   %%%%% use the unwrapped phase to extract h(t) and r(t)
xlabel("time (s)");
ylabel("Displacement(t) (mm)");

displacement=zeros(1,length(LPF_I_t));


for n=2:length(LPF_I_t)%%%%attention that n begins from 2
    bridge=0;
    for k=2:n
        bridge=bridge+1000*(lamda/(4*pi))*(LPF_I_t(1,k-1)*LPF_Q_t(1,k)-LPF_I_t(1,k)*LPF_Q_t(1,k-1));
    end
    displacement(1,n)=bridge;
end

figure(6)
plot(t,displacement);
xlabel("time (s)");
ylabel("Displacement(t) (mm)/DACM");

%%%%%%%%%%%%%%%%%%%%%%%%%% FFT of phi(t) and displacement(t) %%%%%%%%%%%%%%%%%%%%%%%