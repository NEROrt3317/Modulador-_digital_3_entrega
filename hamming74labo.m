
function seqout = hamming74labo(seqin)
  % Codificador Hamming(7,4) por tabla
  % seqin: cadena de bits (ej. '110100101...')
  % seqout: cadena codificada con Hamming(7,4)

  Tabla = ['0000000'; '0001011'; '0010111'; '0011100';
           '0100110'; '0101101'; '0110001'; '0111010';
           '1000101'; '1001110'; '1010010'; '1011001';
           '1100011'; '1101000'; '1110100'; '1111111'];

  % Verifica que la longitud sea múltiplo de 4
  sobrantes = mod(length(seqin), 4);
  if sobrantes != 0
    seqin = [seqin repmat('0', 1, 4 - sobrantes)];  % Rellenar con ceros
  end

  % Dividir en bloques de 4 bits
  datos = reshape(seqin, 4, [])';  % Cada fila es un bloque

  % Convertir cada bloque a índice para tabla
  indices = bin2dec(datos) + 1;  % bin2dec da [0–15] → +1 → [1–16]

  % Buscar cada bloque en la tabla
  seqout = '';
  for k = 1:length(indices)
    seqout = [seqout Tabla(indices(k), :)];
  end
end

