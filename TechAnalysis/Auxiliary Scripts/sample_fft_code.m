Fs = 1000;                    % Sampling frequency = sets Freq. resolution
L = 1000;                     % Length of signal = set Freq. span
T = 1/Fs;                     % Sample time
t = (0:L-1)*T;                % Time vector
% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
x = sin(2*pi*50*t) + sin(2*pi*120*t); 
y = x;
plot(Fs*t,y)
xlabel('time (milliseconds)')

Y = fft(y)/L;
Y = fftshift(Y);
f = Fs/2*linspace(-1,1,L); % if you want 0 to be in the middle, you must use fftshift

% frequency span - 2*(Fs/2)=Fs is equal to 1/dt
% freq. resulution df = 1/T (T = time span)
figure()

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y)) 
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

