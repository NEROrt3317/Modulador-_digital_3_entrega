function audio=DCFaudio(bitstr)
%  DCFaudio es un decodificador de audio; convierte una secuencia binaria en un archivo de sonido, usando decodificación con n bits.
%     audio=DCFaudio(bitstr)...
%        "bitstr" es la secuencia binaria de de entrada, la cual es una cadena de caraceres '1' y '0'.
%        "audio" es la variable tipo double que contiene las muestras del sonido recuperado.

bitstr=reshape(bitstr,[],8);
muestras=bin2dec(bitstr);
muestras=muestras/((2^8)/2);
audio=muestras-1;

end
