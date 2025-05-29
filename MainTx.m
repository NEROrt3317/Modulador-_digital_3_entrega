% MainTx.m
% Script principal para codificación Hamming(7,4) con diferentes tipos de información
% El codificador Hamming(7,4) siempre se aplica, sin preguntar al usuario.

% 1. Entrada del usuario
disp('Elija el tipo de archivo que desea transmitir:');
disp('1. Texto');
disp('2. Imagen');
disp('3. Audio');
type_option = input('Seleccione tipo de información (1/2/3): ');

% 2. Selección del archivo y codificación binaria
switch type_option
    case 1  % Codificación de texto
        archivo = input('Ingrese el nombre del archivo de texto: ', 's');
        [bitstr] = CFtexto(archivo);  % Codificador de texto
    case 2  % Codificación de imagen
        archivo = input('Ingrese el nombre del archivo de imagen: ', 's');
        [bitstr, alto, ancho] = CFimagen(archivo);  % Codificador de imagen
    case 3  % Codificación de audio
        archivo = input('Ingrese el nombre del archivo de audio: ', 's');
        [bitstr, fs] = CFaudio(archivo);  % Codificador de audio
    otherwise
        disp('Opción no válida. El programa se detendrá.');
        return;
end

% 3. Aplicación de FEC (Codificación Hamming(7,4))
disp('Aplicando codificación Hamming(7,4)...');
bitstr = hamming74labo(bitstr);  % Codificador Hamming(7,4)

% 4. Mostrar resultado o guardar archivo de salida
disp('Secuencia binaria codificada:');
disp(bitstr);  % Imprime la secuencia binaria resultante

MainTxMod;


