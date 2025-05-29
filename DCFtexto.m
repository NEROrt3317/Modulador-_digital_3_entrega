function texto=DCFtexto(bitstr)
%  DCFtxt es un decodificador de texto; convierte una secuencia binaria en una cadena de texto.
%     texto=DCFtexto(bitstr)...
%        "bitstr" es la secuencia binaria de entrada que se desea decodificar, la cual también es una cadena de caraceres '1' y '0'.
%        "texto" es la variable tipo cadena de caracteres (texto) que se recupera a la salida.

bits=reshape(bitstr,[],8);
texto=bin2dec(bits);
texto=char(texto)';

end