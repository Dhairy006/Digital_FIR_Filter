clear; clc;

if exist('ecg_muscle_noise.mat','file') ~= 2
    error('ecg_muscle_noise.mat not found in current folder.');
end
S = load('ecg_muscle_noise.mat');

if ~isfield(S,'noisy_seg')
    error('Variable noisy_seg not found in ecg_muscle_noise.mat');
end
noisy_seg = S.noisy_seg;

Fs = 360;
N = 35; 
Fc = 40;
Wn = Fc / (Fs/2);
b = fir1(N-1, Wn, 'low', hann(N));
b_single = single(b(:));     
noisy_single = single(noisy_seg(:)); 

to_hex = @(x) sprintf('%08X', typecast(single(x), 'uint32'));

coeffs_fname = 'coeffs.mem';
fid = fopen(coeffs_fname, 'w');
if fid == -1
    error('Could not open %s for writing.', coeffs_fname);
end
fprintf('%s: writing %d coefficients to %s\n', datetime('now'), numel(b_single), coeffs_fname);
for k = 1:numel(b_single)
    fprintf(fid, '%s\n', to_hex(b_single(k)));
end
fclose(fid);

input_fname = 'input_noisy.mem';
fid = fopen(input_fname, 'w');
if fid == -1
    error('Could not open %s for writing.', input_fname);
end
fprintf('%s: writing %d noisy samples to %s\n', datetime('now'), numel(noisy_single), input_fname);
for k = 1:numel(noisy_single)
    fprintf(fid, '%s\n', to_hex(noisy_single(k)));
end
fclose(fid);

len_fname = 'input_length.txt';
fid = fopen(len_fname, 'w');
fprintf(fid, '%d\n', numel(noisy_single));
fclose(fid);

fprintf('Done. Files created:\n  %s\n  %s\n  %s\n', coeffs_fname, input_fname, len_fname);
