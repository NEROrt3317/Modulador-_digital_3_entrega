[bitsrx,simbolosrx]=ModRx(SenalRx,M);
% "bitsrx" es la secuancia binaria demodulada en recepción (recibida).
% "simbolosrx" son los símbolos recibidos, en formato entero.

SER=sum(simbolosrx~=simbolos)/length(simbolos) % Cálculo de la tasa de errores de símbolo
BER=sum(bitsrx~=bits)/length(bits) % Cálculo de la tasa de errores de bit

