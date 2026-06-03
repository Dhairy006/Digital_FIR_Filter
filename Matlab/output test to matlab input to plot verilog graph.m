clc; clear; close all;

filename = 'output.txt';

fid = fopen(filename, 'r');
if fid == -1
    error('Could not open %s', filename);
end

hexData = textscan(fid, '%s'); 
fclose(fid);

hexStrings = hexData{1};
N = length(hexStrings);
out_float = zeros(N, 1, 'single');

for i = 1:N
    out_float(i) = typecast(uint32(hex2dec(hexStrings{i})), 'single');
end
figure;
plot(out_float, 'LineWidth', 1.2);
xlabel('Sample Index');
ylabel('Amplitude');
title('Filtered ECG Output (From Verilog FIR)');
grid on;
