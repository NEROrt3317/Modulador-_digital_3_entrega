function [bitstr,fs]=CFaudio(Narchivo)
%  CFaudio es un codificador de audio; convierte un archivo de sonido en una secuencia binaria, usando cuantización lineal y codificación con 8 bits.
%     [bitstr,fs]=CFaudio(Narchivo)...
%        "Narchivo" es el nombre del archivo de audio que se quiere digitalizar.
%        "bitstr" es la secuencia binaria de salida, la cual es una cadena de caraceres '1' y '0'.
%        "fs" es la frecuencia de muestreo a la cual fue capturado el audio.

[audio,fs]=audioread(Narchivo);
audio=audio(:,1);
audio=audio/max(abs(audio));
audio=(audio+1)/2;
muestras=round(audio*((2^8)-1)); % Codificacion con n bits
bits=dec2bin(muestras,8);
bitstr=reshape(bits,1,[]);

end
