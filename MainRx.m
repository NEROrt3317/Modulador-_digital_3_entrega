
MainRxDemod;
bitstr = bitsrx ;

disp("=== Receptor ===");
fec = input("¿Se usó FEC Hamming(7,4) en la transmisión? (s/n): ", "s");



% Si se usó FEC, decodificamos Hamming(7,4)
if lower(fec) == 's'
    disp("Aplicando decodificación Hamming(7,4)...");
    bitstr = Hamming74dec_tabla(bitstr);  % <- función de decodificación FEC
end

% Elegir el tipo de información a decodificar
% Para las imagenes debemos usar lo siguiente
%info = imfinfo('nombre_de_la_imagen.ext');
%alto = info.Height;
%ancho = info.Width;


disp("Seleccione el tipo de información a decodificar:");
disp("1. Texto");
disp("2. Imagen");
disp("3. Audio");
opcion = input("Ingrese su opción (1/2/3): ");

switch opcion
    case 1
        texto = DCFtexto(bitstr);
        disp("Texto decodificado:");
        disp(texto);

    case 2
        alto = input("Ingrese el alto de la imagen: ");
        ancho = input("Ingrese el ancho de la imagen: ");
        imagen = DCFimagen(bitstr, alto, ancho);
        imshow(imagen);
        imwrite(imagen, 'imagen_recibida.png');
        disp("Imagen reconstruida guardada como 'imagen_recibida.png'");

    case 3
        audio = DCFaudio(bitstr);
        sound(audio, 44100);  % Frecuencia de muestreo asumida
        audiowrite("audio_recuperado.wav", audio, 44100);
        disp("Audio reconstruido guardado como 'audio_recuperado.wav'");

    otherwise
        disp("Opción inválida.");
end

