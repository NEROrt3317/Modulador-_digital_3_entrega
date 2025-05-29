function imagen=DCFimagen(bitstr,alto,ancho)
%  DCFimagen es un decodificador de imagen; convierte una secuencia binaria en una imagen de cierto tamaño especificado, usando modelo RGB de 24 bits.
%     imagen=DCFimagen(bitstr,alto,ancho)...
%        "bitstr" es la secuencia binaria de de entrada, la cual es una cadena de caraceres '1' y '0'.
%        "alto" es el alto de la imagen en pixels.
%        "ancho" es el ancho de la imagen en pixels.

w=reshape(bitstr,[],8);
y=bin2dec(w);
x=reshape(y,alto,ancho,3);
imagen=uint8(x);

end