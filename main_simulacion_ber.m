% main_simulador.m
clc;
clear;

% 1. Parámetros de la simulación
num_bits_fuente = 5 * 10^6; % 5 Millones de bits
SNR_dB_range = -5:1:20; % Rango de SNR en dB
num_SNR_points = length(SNR_dB_range);

% --- MODIFICACIÓN AQUÍ: SOLO INCLUIMOS MODULACIONES COMPATIBLES CON qamdemod ---
% M debe ser un cuadrado de una potencia de 2 para qamdemod
modulations = {
    struct('M', 4, 'type', 'QAM', 'is_qam', true, 'name', 'QPSK (4-QAM)'), % QPSK es compatible con qamdemod (4 = 2^2)
    struct('M', 16, 'type', 'QAM', 'is_qam', true, 'name', '16QAM'),     % 16QAM es compatible (16 = 4^2)
    struct('M', 64, 'type', 'QAM', 'is_qam', true, 'name', '64QAM'),     % 64QAM es compatible (64 = 8^2)
    struct('M', 1024, 'type', 'QAM', 'is_qam', true, 'name', '1024QAM')  % 1024QAM es compatible (1024 = 32^2)
};
% NOTA IMPORTANTE: BPSK (M=2) y 16PSK (M=16) HAN SIDO ELIMINADAS
% ya que ModRx.m usa qamdemod, el cual no soporta M=2 o PSK.

% Inicializar matrices para almacenar resultados
BER_results_no_fec = zeros(num_SNR_points, length(modulations));
SER_results_no_fec = zeros(num_SNR_points, length(modulations));
BER_results_with_fec = zeros(num_SNR_points, length(modulations));
SER_results_with_fec = zeros(num_SNR_points, length(modulations));

% 2. Generar la secuencia de bits de fuente (original)
original_bits_str = num2str(randi([0 1], num_bits_fuente, 1))';

% Bucle principal de Modulaciones
for mod_idx = 1:length(modulations)
    current_mod = modulations{mod_idx};
    M = current_mod.M;
    n_bits_per_symbol = log2(M); % Calcular n_bits_per_symbol
    is_qam_tx = current_mod.is_qam; % Para ModTx (aquí siempre será true)

    disp(['Simulando para ', current_mod.name, ' (M=', num2str(M), ')...']);

    % Escenario SIN FEC
    disp('  -- Escenario SIN FEC --');
    % Preparar bits para el modulador (posible padding en ModTx)
    bits_to_mod_no_fec = original_bits_str; % Los bits de fuente directos

    % Bucle de SNR
    for snr_idx = 1:num_SNR_points
        SNR_dB = SNR_dB_range(snr_idx);
        % Llamada a ModTx
        [simbolos_tx_no_fec, SenalTx_no_fec] = ModTx(bits_to_mod_no_fec, 1, M, is_qam_tx); % Rb=1 solo un valor dummy, no afecta la mod

        % Añadir ruido AWGN
        SenalRx_no_fec = awgn(SenalTx_no_fec, SNR_dB, 'measured');

        % Llamada a ModRx (ahora M será compatible con qamdemod)
        % Nota: Aunque pasamos is_qam_tx=true a ModTx, ModRx NO USA ese parámetro.
        % Lo importante es que el 'M' que se le pasa a ModRx (que es M=4, 16, 64, 1024)
        % es ahora compatible con la función qamdemod.
        [bitsrx_no_fec, simbolosrx_no_fec] = ModRx(SenalRx_no_fec, M); % <--- Aquí la llamada a tu ModRx

        % Recortar bits y símbolos recibidos al tamaño original de los bits_to_mod_no_fec (deshacer padding de ModTx si lo hubo)
        % Para el cálculo de BER/SER, necesitamos que bitsrx y simbolosrx tengan la misma longitud que los originales ANTES de ModTx
        % Simplemente comparamos con los que se pasaron a ModTx

        % ModTx añade padding si la longitud de entrada no es múltiplo de n.
        % La longitud de bitsrx_no_fec puede ser diferente de bits_to_mod_no_fec debido a este padding
        % Necesitamos que coincidan para la comparación BER.
        len_bits_tx_original = length(bits_to_mod_no_fec);
        if length(bitsrx_no_fec) > len_bits_tx_original
            bitsrx_no_fec_trimmed = bitsrx_no_fec(1:len_bits_tx_original);
        else
            bitsrx_no_fec_trimmed = bitsrx_no_fec;
        end

        % Símbolos también pueden tener diferente longitud si hubo padding en ModTx
        % Sin embargo, SER se calcula en base a la longitud de los simbolos_tx_no_fec
        % que ya incluye el padding de ModTx. Así que no necesita trimming.

        % Asegurarse que simbolosrx_no_fec tenga la misma longitud que simbolos_tx_no_fec
        len_simbolos_tx = length(simbolos_tx_no_fec);
        if length(simbolosrx_no_fec) > len_simbolos_tx
             simbolosrx_no_fec_trimmed_for_ser = simbolosrx_no_fec(1:len_simbolos_tx);
        else
             simbolosrx_no_fec_trimmed_for_ser = simbolosrx_no_fec;
        end


        SER_results_no_fec(snr_idx, mod_idx) = sum(simbolosrx_no_fec_trimmed_for_ser ~= simbolos_tx_no_fec) / length(simbolos_tx_no_fec);
        BER_results_no_fec(snr_idx, mod_idx) = sum(bitsrx_no_fec_trimmed ~= bits_to_mod_no_fec) / length(bits_to_mod_no_fec);

        % Limitar BER/SER a un valor mínimo si son 0 (para graficar en escala logarítmica)
        if SER_results_no_fec(snr_idx, mod_idx) == 0, SER_results_no_fec(snr_idx, mod_idx) = 1e-10; endif; % Evitar log(0)
        if BER_results_no_fec(snr_idx, mod_idx) == 0, BER_results_no_fec(snr_idx, mod_idx) = 1e-10; endif;
    end

    % Escenario CON FEC (Hamming(7,4))
    disp('  -- Escenario CON FEC (Hamming(7,4)) --');
    % Codificar con Hamming(7,4)
    bits_fec_encoded = hamming74labo(original_bits_str); % Esto es lo que va al modulador

    % Bucle de SNR
    for snr_idx = 1:num_SNR_points
        SNR_dB = SNR_dB_range(snr_idx);

        % Llamada a ModTx
        [simbolos_tx_fec, SenalTx_fec] = ModTx(bits_fec_encoded, 1, M, is_qam_tx);

        % Añadir ruido AWGN
        SenalRx_fec = awgn(SenalTx_fec, SNR_dB, 'measured');

        % Llamada a ModRx (ahora M será compatible con qamdemod)
        [bitsrx_fec_raw, simbolosrx_fec] = ModRx(SenalRx_fec, M); % Bits recibidos sin decodificar FEC

        % --- Manejo de longitudes para decodificación FEC y comparación BER ---
        % bitsrx_fec_raw debe tener la misma longitud que bits_fec_encoded
        % antes de ser pasado a Hamming74dec_tabla.
        len_bits_fec_encoded_tx = length(bits_fec_encoded);
        if length(bitsrx_fec_raw) > len_bits_fec_encoded_tx
            bitsrx_fec_raw_trimmed = bitsrx_fec_raw(1:len_bits_fec_encoded_tx);
        else
            bitsrx_fec_raw_trimmed = bitsrx_fec_raw;
        end

        % Hamming74dec_tabla asume que la entrada es un múltiplo de 7.
        % Puede que bitsrx_fec_raw_trimmed necesite padding si su longitud no es múltiplo de 7.
        % Esto es crucial si el ruido causa una pérdida de bits que altera la longitud
        % (aunque con AWGN esto no debería suceder a menos que haya truncamiento en algún lugar)
        sobrantes_fec_rx = mod(length(bitsrx_fec_raw_trimmed), 7);
        if sobrantes_fec_rx ~= 0
            bitsrx_fec_raw_padded = [bitsrx_fec_raw_trimmed repmat('0', 1, 7 - sobrantes_fec_rx)];
        else
            bitsrx_fec_raw_padded = bitsrx_fec_raw_trimmed;
        end

        % Decodificar con Hamming(7,4)
        bits_fec_decoded = Hamming74dec_tabla(bitsrx_fec_raw_padded);

        % Los bits decodificados (bits_fec_decoded) deben compararse con los ORIGINALES (original_bits_str)
        % NOTA: hamming74labo puede añadir ceros de relleno al final de original_bits_str
        % Debemos recortar bits_fec_decoded a la longitud de original_bits_str para una comparación precisa.
        len_original_bits = length(original_bits_str);
        if length(bits_fec_decoded) > len_original_bits
            bits_fec_decoded_trimmed = bits_fec_decoded(1:len_original_bits);
        else
            bits_fec_decoded_trimmed = bits_fec_decoded;
        end

        BER_results_with_fec(snr_idx, mod_idx) = sum(bits_fec_decoded_trimmed ~= original_bits_str) / len_original_bits;

        % SER para FEC se calcula a nivel del demodulador, antes de la decodificación de canal.
        % Asegurarse que simbolosrx_fec tenga la misma longitud que simbolos_tx_fec
        len_simbolos_tx_fec = length(simbolos_tx_fec);
        if length(simbolosrx_fec) > len_simbolos_tx_fec
             simbolosrx_fec_trimmed_for_ser = simbolosrx_fec(1:len_simbolos_tx_fec);
        else
             simbolosrx_fec_trimmed_for_ser = simbolosrx_fec;
        end

        SER_results_with_fec(snr_idx, mod_idx) = sum(simbolosrx_fec_trimmed_for_ser ~= simbolos_tx_fec) / length(simbolos_tx_fec);

        % Limitar BER/SER a un valor mínimo si son 0 (para graficar en escala logarítmica)
        if SER_results_with_fec(snr_idx, mod_idx) == 0, SER_results_with_fec(snr_idx, mod_idx) = 1e-10; endif;
        if BER_results_with_fec(snr_idx, mod_idx) == 0, BER_results_with_fec(snr_idx, mod_idx) = 1e-10; endif;
    end
end

% 7. Graficar los resultados

% Figuras para BER vs SNR
figure;
h_ber = []; % Para guardar los handles de las líneas y la leyenda
plot_colors = {'b', 'g', 'r', 'm', 'c', 'k', 'y'}; % Más colores si es necesario
line_styles = {'-', '--'}; % Sólida para no FEC, discontinua para FEC

% Asegúrate de que los DisplayName sean correctos para las nuevas modulaciones
for mod_idx = 1:length(modulations)
    mod_name = modulations{mod_idx}.name;

    % Sin FEC
    plot_handle = semilogy(SNR_dB_range, BER_results_no_fec(:, mod_idx), [plot_colors{mod_idx}, line_styles{1}, 'o'], 'DisplayName', [mod_name, ' - No FEC']); hold on;
    h_ber = [h_ber, plot_handle];

    % Con FEC
    plot_handle = semilogy(SNR_dB_range, BER_results_with_fec(:, mod_idx), [plot_colors{mod_idx}, line_styles{2}, 'x'], 'DisplayName', [mod_name, ' - Con FEC']);
    h_ber = [h_ber, plot_handle];
end

title('BER vs SNR para Diferentes Modulaciones (Con y Sin FEC)');
xlabel('SNR [dB]');
ylabel('BER');
grid on;
legend(h_ber, 'Location', 'southwest'); % 'southwest' suele ser bueno para BER
ylim([1e-6 1]); % Ajustar límites para mejor visualización
hold off;

% Figuras para SER vs SNR
figure;
h_ser = []; % Para guardar los handles de las líneas y la leyenda

for mod_idx = 1:length(modulations)
    mod_name = modulations{mod_idx}.name;

    % Sin FEC
    plot_handle = semilogy(SNR_dB_range, SER_results_no_fec(:, mod_idx), [plot_colors{mod_idx}, line_styles{1}, 'o'], 'DisplayName', [mod_name, ' - No FEC']); hold on;
    h_ser = [h_ser, plot_handle];

    % Con FEC (SER en demodulador, antes de decodificación FEC)
    plot_handle = semilogy(SNR_dB_range, SER_results_with_fec(:, mod_idx), [plot_colors{mod_idx}, line_styles{2}, 'x'], 'DisplayName', [mod_name, ' - Con FEC (SER en demodulador)']);
    h_ser = [h_ser, plot_handle];
end

title('SER vs SNR para Diferentes Modulaciones (Con y Sin FEC)');
xlabel('SNR [dB]');
ylabel('SER');
grid on;
legend(h_ser, 'Location', 'southwest'); % 'southwest' suele ser bueno para SER
ylim([1e-6 1]); % Ajustar límites para mejor visualización
hold off;
