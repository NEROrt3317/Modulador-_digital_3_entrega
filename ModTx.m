function [simbolos, modulada] = ModTx(seq, Rb, M, is_qam) % <--- Añadido is_qam aquí
% ModTx.m
% Función para modulación digital (QAM o PSK).
% Genera los símbolos en el espacio de señal (puntos de constelación).
%
% Sintaxis:
%   [simbolos, modulada] = ModTx(seq, Rb, M, is_qam)
%
% Parámetros:
%   seq     : Secuencia de bits de entrada (cadena de caracteres '0' y '1').
%   Rb      : Tasa de bits de entrada [bps].
%   M       : Orden de la modulación.
%   is_qam  : Booleano (true/false o 1/0).
%             true (o 1) si es QAM.
%             false (o 0) si es PSK (incluyendo BPSK, QPSK).
%
% Retorna:
%   simbolos : Vector de índices de los símbolos (enteros de 0 a M-1).
%   modulada : Vector de símbolos complejos en el espacio de señal.

n = log2(M); % Bits por cada símbolo de la modulación

% --- Asegurarse de que la longitud de 'seq' sea un múltiplo de 'n' (importante para reshape) ---
sobrantes = mod(length(seq), n);
if sobrantes ~= 0
    seq = [seq repmat('0', 1, n - sobrantes)]; % Rellenar con ceros
    disp(['Advertencia: Secuencia de entrada rellenada con ', num2str(n - sobrantes), ' ceros en ModTx.']);
end
% --- Fin del ajuste de longitud ---

R = Rb/n; % Tasa de símbolos a la cual se está transmitiendo [baud]
T = 1/R; % Periodo de símbolo [s]
alfa = 0.2; % Factor de roll-off del filtro de transmisión
Btx = R*(1+alfa); % Ancho de banda de transmisión [Hz]

simbolos = bin2dec(reshape(seq,[],n));

% --- MODIFICACIÓN CLAVE (solo una línea extra de lógica) ---
if is_qam
    modulada = qammod(simbolos, M); % Modulación QAM
else
    modulada = pskmod(simbolos, M); % Modulación PSK (incluye BPSK, QPSK)
end
% --- Fin de la MODIFICACIÓN CLAVE ---

end
