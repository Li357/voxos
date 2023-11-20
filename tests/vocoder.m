fs = 48000;
order = 4;
shift = 20; % 2^20 multiplication for fixed-point arithmetic

% voice frequency range in Hz split into n_bands log-spaced
lo = 55;
hi = 7040;
n_bands = 16;

bands = logspace(log10(lo), log10(hi), n_bands);

% assumes that fvox = fsam = fs
[vox, fvox] = audioread('voice.wav');      % modulator
[sample, fsam] = audioread('trumpet.wav'); % carrier
sample = sample(1:size(vox));              % trim carrier to modulator length

% plot the original
subplot(n_bands, 1, 1);
plot(vox);
title('Original');
xlabel('Time (s)');
ylabel('Amplitude');

sz = num2cell(size(vox));
vocoded = zeros(sz{:});
unmodulated = zeros(sz{:});

coeffs = zeros(n_bands, 10);

% LPF for envelope detection, 100Hz is a guestimate
lpf = designfilt("lowpassiir", ...
                  FilterOrder=order, ...
                  HalfPowerFrequency=100, ...
                  SampleRate=fs, ...
                  DesignMethod="butter");

for i = 1:(n_bands-1)
    df = designfilt("bandpassiir", ...
                    FilterOrder=order, ...
                    HalfPowerFrequency1=bands(i), ...
                    HalfPowerFrequency2=bands(i+1), ...
                    SampleRate=fs, ...
                    DesignMethod="butter");

    coeffs(i,:) = [df.Coefficients(1:1,1:3), df.Coefficients(1:1,5:6), df.Coefficients(2:2,1:3), df.Coefficients(2:2,5:6)];

    filtered_vox = filter(df, vox);
    env_lpf = filter(lpf, abs(filtered_vox));       % rectify the signal and run thru LPF for envelope
    filtered_samp = filter(df, sample);

    vocoded = vocoded + (env_lpf .* filtered_samp); % use envelope to modulate carrier in corresponding bands
                                                    % and mix signals back together

    unmodulated = unmodulated + filtered_vox;

    subplot(n_bands, 1, i+1);
    plot(filtered_vox);
    title(strcat('Filter ', i));
    xlabel('Time (s)');
    ylabel('Amplitude');

    hold on

    plot(env_lpf);
    title(strcat('Envelope ', i));
    xlabel('Time (s)');
    ylabel('Amplitude');
end

sound(10 * vocoded, fs); % get some gain

coeffs(n_bands,:) = [lpf.Coefficients(1:1,1:3), lpf.Coefficients(1:1,5:6),lpf.Coefficients(2:2,1:3), lpf.Coefficients(2:2,5:6)];

% now write the coefficients to a file for Verilog $readmemh
scaled_coeffs = round(vpa(coeffs) .* 2^(shift)); % more precision and apply FPA shift
fd = fopen('../data/coeffs.mem', 'w');
% annoying ugly for loop because matlab indexing is atrocious
for j = 1:n_bands
    for k = 1:10
        fprintf(fd, '%s', dec2hex(scaled_coeffs(j,k), 8));
        if k < 10 
            fprintf(fd, ' ');
        end
    end
    fprintf(fd, '\n');
end
fclose(fd);
