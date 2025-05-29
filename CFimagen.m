function [bitstr,alto,ancho]=CFimagen(Narchivo)
%  CFimagen es un codificador de imagen; convierte un archivo de imagen en una secuencia binaria, usando el modelo RGB de 24 bits.
%     [bitstr,alto,ancho]=CFimagen(Narchivo)...
%        "Narchivo" es el nombre del archivo de imagen que se desea digitalizar.
%        "bitstr" es la secuencia binaria de salida, la cual es una cadena de caraceres '1' y '0'.
%        "alto" es el alto de la imagen en pixels.
%        "ancho" es el ancho de la imagen en pixels.

imagen=imread(Narchivo);
[alto,ancho,prof]=size(imagen);
x=double(imagen);
y=reshape(x,[],1);
w=dec2bin(y,8);
bitstr=reshape(w,1,[]);

end