function [bitsrx,simbolosrx]=ModRx(senalrx,M)

n=log2(M); % Bits por símbolo de modulación
simbolosrx=qamdemod(senalrx,M); % Símbolos detectados a partir de la señal recibida, enformato entero
bitsrx=dec2bin(simbolosrx,n);
bitsrx=reshape(bitsrx,1,[]); % Secuencia binaria demodulada

end

