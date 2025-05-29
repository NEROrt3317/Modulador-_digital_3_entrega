function datos_out = Hamming74dec_tabla(seqin)
  % Tabla de códigos válidos Hamming(7,4)
  Tabla = ['0000000'; '0001011'; '0010111'; '0011100';
           '0100110'; '0101101'; '0110001'; '0111010';
           '1000101'; '1001110'; '1010010'; '1011001';
           '1100011'; '1101000'; '1110100'; '1111111'];

  datos_out = '';
  bloques = reshape(seqin, 7, []).';

  for i = 1:size(bloques, 1)
    bloque = bloques(i, :);
    mejor_match = '';
    menor_distancia = 8; % la máxima distancia Hamming posible es 7
    indice_match = 0;

    for j = 1:16
      codigo = Tabla(j, :);
      % Comparar bit a bit
      distancia = sum(bloque != codigo);
      if distancia < menor_distancia
        menor_distancia = distancia;
        mejor_match = codigo;
        indice_match = j;
        if distancia == 0
          break; % ya encontramos el correcto
        endif
      endif
    endfor

    % Convertir índice a número binario de 4 bits
    indice_bin = dec2bin(indice_match - 1, 4); % porque el índice va de 1 a 16
    datos_out = [datos_out, indice_bin];
  endfor
end

