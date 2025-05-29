% MainTx.m (Versión para modulaciones digitales)
%clc;
%clear;

%bits = num2str(randi([0 1],151200,1))'; % bits es la secuencia que sale del codificador Hamming(7,4)

bits = bitstr

Rb = input('Indique la tasa de transmisión [bps]: ');
M = input('Indique el número de simbolos de la modulación (ej. 2, 4, 16, 64): ');

% --- AGREGAMOS LA PREGUNTA AL USUARIO AQUÍ ---
disp(' '); % Espacio para claridad
disp('Seleccione el tipo de modulación para M = ');
disp('1. PSK (BPSK, QPSK, 8PSK, 16PSK, etc.)');
disp('2. QAM (16QAM, 64QAM, etc.)');
mod_choice_type = input('Ingrese su opción (1=PSK, 2=QAM): ');

is_qam_mod = false; % Por defecto, asumimos PSK
if mod_choice_type == 2
    is_qam_mod = true; % Si el usuario elige 2, entonces es QAM
elseif mod_choice_type ~= 1
    error('Opción de tipo de modulación no válida. Por favor, use 1 o 2.');
end
% --- FIN DE LA PREGUNTA AL USUARIO ---

% --- Validación básica de M para el tipo seleccionado (Opcional, pero ayuda) ---
if is_qam_mod
    % Para QAM, M debe ser una potencia de 2 y usualmente M >= 16 para diferenciar de QPSK
    if mod(log2(M), 1) ~= 0 || M < 4 % QAM M=4 es QPSK
        error('Para QAM, M debe ser una potencia de 2 (ej. 4, 16, 64...) y usualmente M>=16. 4-QAM es lo mismo que QPSK.');
    end
else % Es PSK
    % Para PSK, M debe ser una potencia de 2 y M >= 2
    if mod(log2(M), 1) ~= 0 || M < 2
        error('Para PSK, M debe ser una potencia de 2 (ej. 2, 4, 8, 16...) y M>=2.');
    end
end
% --- FIN Validación ---


SNR = input('Cuál es la SNR en recepción [dB]: ');

% --- LLAMADA A LA FUNCIÓN ModTx, PASANDO EL NUEVO PARÁMETRO is_qam_mod ---
[simbolos, SenalTx] = ModTx(bits, Rb, M, is_qam_mod);
% "simbolos" son los símbolos que se van a transmitir en formato entero (índices).
% "SenalTx" son los símbolos que se van a transmitir en formato a+jb (constelación).

SenalRx = awgn(SenalTx, SNR, 'measured');
% "SenalRx" son los símbolos recibidos después de pasar por el canal con un SNR dada, en formato c+jd.

% Descomente la siguiente línea si desea visualizar los símbolos transmitidos y los recibidos
plot(SenalRx,'r*'); grid on; hold on; plot(SenalTx,'bo');
title(sprintf('Constelación de la Modulación M=%d (SNR=%.1f dB)', M, SNR));
legend('Símbolos recibidos','Símbolos transmitidos');
hold off;

% Cálculo de la tasa de errores de símbolo y bit (asume que MainRx.m se ejecutará después o se integrará)
% SER = sum(simbolos~=simbolos_rx) / length(simbolos);
% BER = sum(bits~=bits_rx) / length(bits);
