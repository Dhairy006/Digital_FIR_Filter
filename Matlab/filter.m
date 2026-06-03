clc; clear; close all;
load('ecg_muscle_noise.mat');

Fs = 360;
N = 35;
Fc = 40;
n = 1:1024;
t = (0:length(noisy_seg)-1)/Fs;

Wn = Fc / (Fs/2);
b = fir1(N-1, Wn, 'low', hann(N));

[H, f] = freqz(b, 1, 1024, Fs);

figure;
plot(n,noisy_seg);
xlabel('Sample no.');
ylabel('Amplitude');
title('Plot of the noisy ECG signal');
grid on;

figure;
subplot(2,1,1);
plot(f, 20*log10(abs(H)));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude response of the filter');
grid on;

subplot(2,1,2);
plot(f, unwrap(angle(H)));
xlabel('Frequency (Hz)');
ylabel('Phase (radians)');
title('Phase response of the filter');
grid on;

ecg_filtered = filtfilt(b, 1, noisy_seg);

figure;
plot(t, noisy_seg);
hold on;
plot(t, ecg_filtered);
hold on;
plot(t, clean_seg);
xlabel('Time (s)');
ylabel('Amplitude');
legend('Noisy ECG','Filtered ECG','Clean ECG');
title('Plot of noisy and filtered ECG in time domain');
grid on;

L = length(noisy_seg);
f_axis = (0:L-1)*(Fs/L);
FFT_noisy = abs(fft(noisy_seg));
FFT_filtered = abs(fft(ecg_filtered));

figure;
plot(f_axis, FFT_noisy);
hold on;
plot(f_axis, FFT_filtered);
xlim([0 100]);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend('Noisy ECG','Filtered ECG');
title('Plot of noisy and filtered ECG in freq domain');
grid on;

noise_before = noisy_seg - clean_seg;
noise_after = ecg_filtered - clean_seg;
snr_before = snr(clean_seg, noise_before);
snr_after = snr(clean_seg, noise_after);
fprintf('SNR before filtering: %.2f dB\n', snr_before);
fprintf('SNR after filtering: %.2f dB\n', snr_after);
fprintf('SNR Improvement: %.2f dB\n', snr_after - snr_before);