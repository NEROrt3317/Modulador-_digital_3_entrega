function bitstr=CFtexto(Narchivo)
%  CFtexto es un codificador de texto; convierte un archivo de texto en una secuencia binaria.
%     bitstr=CFtexto(Narchivo)...
%        "Narchivo" es el nombre del archivo de texto que se desea digitalizar.
%        "bitstr" es la secuencia binaria de salida, la cual es una cadena de caraceres '1' y '0'.

fid=fopen(Narchivo,'r');
texto=fscanf(fid,'%c');
texto=double(texto');
bits=dec2bin(texto,8);
bitstr=reshape(bits,1,[]);

end