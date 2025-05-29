# Simulador de Sistema de Comunicaciones Digitales

Este repositorio contiene la implementación de un sistema de comunicaciones digitales simplificado, enfocado en la codificación de fuente, codificación de canal, modulación, demodulación y simulación de rendimiento en un canal con ruido AWGN. El objetivo principal es analizar el comportamiento de diferentes esquemas de modulación (QAM y PSK) con y sin el uso de codificación de canal (FEC) mediante curvas de Tasa de Error de Bit (BER) y Tasa de Error de Símbolo (SER) versus la Relación Señal a Ruido (SNR).

El proyecto está desarrollado en Octave y utiliza las funciones de procesamiento de señal disponibles en este entorno.

## Diagrama de Bloques del Sistema

El sistema implementa una cadena de comunicación digital con los siguientes módulos:

![Diagrama de Bloques del Sistema](image_cc4d15.png)


## Estructura del Repositorio

El repositorio contiene los siguientes archivos `.m`, cada uno con una función específica dentro del sistema:

* **`CFaudio.m`**: Codificador de Fuente para audio.
* **`CFimagen.m`**: Codificador de Fuente para imagen.
* **`CFtexto.m`**: Codificador de Fuente para texto.
* **`DCFaudio.m`**: Decodificador de Fuente para audio.
* **`DCFimagen.m`**: Decodificador de Fuente para imagen.
* **`DCFtexto.m`**: Decodificador de Fuente para texto.
* **`hamming74labo.m`**: Codificador de Canal (Hamming(7,4)).
* **`Hamming74dec_tabla.m`**: Decodificador de Canal (Hamming(7,4) basado en tabla de búsqueda).
* **`ModTx.m`**: Módulo de Modulación Digital.
* **`ModRx.m`**: Módulo de Demodulación Digital.
* **`MainTxMod.m`**: Script principal para el proceso de modulación y adición de ruido.
* **`MainRxDemod.m`**: Script principal para el proceso de demodulación y cálculo de BER/SER.
* **`main_simulador_ber.m`**: **(NUEVO)** Script principal para simular curvas de BER/SER vs SNR con 5 millones de bits.
* **`teorico_ber_ser.m`**: **(NUEVO)** Script para graficar curvas teóricas de BER/SER vs SNR (solo con fines ilustrativos).

## Descripción de los Módulos

A continuación se detalla la función de cada archivo en el proyecto:

### Módulos de Codificación/Decodificación de Fuente

Estos módulos se encargan de preparar los datos de diferentes tipos (audio, imagen, texto) para la transmisión y de reconstruirlos en recepción.

* **`CFaudio.m`**
    * **Función:** Convierte un archivo de audio (WAV) en una secuencia binaria. Realiza la cuantificación y la serialización de los bits.
    * **Entrada:** Ruta al archivo de audio.
    * **Salida:** `bitstr` (cadena de caracteres '0' y '1').
* **`DCFaudio.m`**
    * **Función:** Decodifica una secuencia binaria en un archivo de audio WAV. Recupera las muestras de sonido a partir de los bits recibidos.
    * **Entrada:** `bitstr` (cadena de caracteres '0' y '1').
    * **Salida:** Archivo de audio recuperado.
* **`CFimagen.m`**
    * **Función:** Convierte una imagen (BMP, JPG, etc.) a una secuencia binaria. Puede incluir compresión o simplemente la serialización de los píxeles.
    * **Entrada:** Ruta al archivo de imagen.
    * **Salida:** `bitstr` (cadena de caracteres '0' y '1').
* **`DCFimagen.m`**
    * **Función:** Decodifica una secuencia binaria en una imagen. Reconstruye la imagen a partir de los bits recibidos.
    * **Entrada:** `bitstr` (cadena de caracteres '0' y '1').
    * **Salida:** Archivo de imagen recuperado.
* **`CFtexto.m`**
    * **Función:** Convierte un archivo de texto en una secuencia binaria. Utiliza codificación ASCII o similar para representar los caracteres.
    * **Entrada:** Ruta al archivo de texto.
    * **Salida:** `bitstr` (cadena de caracteres '0' y '1').
* **`DCFtexto.m`**
    * **Función:** Decodifica una secuencia binaria en un archivo de texto. Recupera el texto original a partir de los bits recibidos.
    * **Entrada:** `bitstr` (cadena de caracteres '0' y '1').
    * **Salida:** Archivo de texto recuperado.

### Módulos de Codificación/Decodificación de Canal (FEC)

Estos módulos añaden redundancia a los bits para protegerlos contra errores introducidos por el canal ruidoso.

* **`hamming74labo.m`**
    * **Función:** Implementa el codificador de canal Hamming(7,4). Toma bloques de 4 bits de información y añade 3 bits de paridad para producir bloques de 7 bits codificados.
    * **Entrada:** `bits` (cadena de caracteres '0' y '1').
    * **Salida:** `bits_codificados` (cadena de caracteres '0' y '1').
    * **Detalles:** Si la longitud de la entrada no es múltiplo de 4, se añade padding al final.
* **`Hamming74dec_tabla.m`**
    * **Función:** Decodifica los bits codificados con Hamming(7,4) utilizando una tabla de búsqueda (síndrome). Es capaz de corregir hasta 1 bit de error por cada bloque de 7 bits.
    * **Entrada:** `bits_recibidos` (cadena de caracteres '0' y '1', potencialmente con errores).
    * **Salida:** `bits_decodificados` (cadena de caracteres '0' y '1').
    * **Detalles:** Asume que la entrada es una secuencia de bloques de 7 bits.

### Módulos de Modulación/Demodulación

Estos módulos convierten los bits en señales analógicas aptas para la transmisión por el canal y viceversa.

* **`ModTx.m`**
    * **Función:** Realiza la modulación de una secuencia de bits. Soporta modulaciones PSK (BPSK, QPSK, 16PSK) y QAM (16QAM, 64QAM, 1024QAM).
    * **Entrada:** `bits` (cadena de caracteres '0' y '1'), `Rb` (tasa de bits, no crucial para la simulación BER/SER), `M` (orden de la modulación), `is_qam` (booleano, `true` para QAM, `false` para PSK).
    * **Salida:** `simbolos` (índices de los símbolos) y `SenalTx` (símbolos complejos modulados).
    * **Detalles:** Utiliza `pskmod` o `qammod` de Octave/MATLAB según el parámetro `is_qam`.
* **`ModRx.m`**
    * **Función:** Realiza la demodulación de una señal recibida.
    * **Entrada:** `SenalRx` (símbolos complejos recibidos), `M` (orden de la modulación).
    * **Salida:** `bitsrx` (secuencia binaria demodulada) y `simbolosrx` (símbolos detectados en formato entero).
    * **Detalles:** **Importante:** Este módulo utiliza **siempre `qamdemod`**. Esto implica que solo las modulaciones compatibles con `qamdemod` (M=4, 16, 64, 1024, etc., donde M es un cuadrado de una potencia de 2) serán demoduladas correctamente. Si `ModTx` usó `pskmod` con `M=2` (BPSK) o `M=16` (16PSK), la demodulación será incorrecta.

### Scripts Principales (para uso manual o prueba)

Estos scripts orquestan partes del proceso de comunicación.

* **`MainTxMod.m`**
    * **Función:** Script interactivo para configurar y ejecutar el proceso de modulación. Solicita al usuario la tasa de transmisión (`Rb`), el orden (`M`) y el tipo de modulación (PSK/QAM). Pasa la secuencia de bits a `ModTx` y luego añade ruido AWGN a la señal modulada.
    * **Salida:** `SenalTx` (señal modulada) y `SenalRx` (señal con ruido). Visualiza la constelación.
* **`MainRxDemod.m`**
    * **Función:** Script para realizar la demodulación de la señal recibida (`SenalRx`) y calcular las Tasas de Error de Símbolo (SER) y Bit (BER).
    * **Entrada (implícita):** Depende de las variables generadas por `MainTxMod.m` en el *workspace* (e.g., `SenalRx`, `M`, `bits`, `simbolos`).
    * **Salida:** `SER` y `BER` calculadas.

## Simulador de Curvas BER/SER (main_simulador_ber.m)

Este es el script principal para generar las curvas de rendimiento BER vs SNR y SER vs SNR para diferentes modulaciones y escenarios de FEC.

* **`main_simulador_ber.m`**
    * **Función:** Simula la cadena de comunicación de extremo a extremo para una gran cantidad de bits (5 millones) a través de un rango de valores de SNR. Realiza la modulación, añade ruido y demodula. También incluye el proceso de codificación/decodificación Hamming(7,4) para comparar el rendimiento con y sin FEC.
    * **Generación de Bits:** Genera una secuencia de 5,000,000 bits aleatorios.
    * **Modulaciones Simuladas:**
        * QPSK (4-QAM)
        * BPSK
        * 16QAM
        * 16PSK
        * 64QAM
        * 1024QAM
    * **Escenarios:**
        * **Sin FEC:** Los bits de la fuente se modulan directamente.
        * **Con FEC:** Los bits de la fuente pasan por `hamming74labo` antes de la modulación, y los bits demodulados pasan por `Hamming74dec_tabla` antes del cálculo de BER.
    * **Cálculo de Errores:** Para cada combinación de modulación, SNR y escenario FEC, se calculan la BER y la SER comparando los bits/símbolos recibidos con los transmitidos originalmente.
    * **Graficación:** Genera dos figuras:
        * **BER vs SNR:** Muestra cómo la Tasa de Error de Bit varía con la SNR.
        * **SER vs SNR:** Muestra cómo la Tasa de Error de Símbolo varía con la SNR.
        * Cada figura contiene múltiples curvas, diferenciadas por color (modulación) y estilo de línea (con/sin FEC), con una leyenda en la esquina superior derecha.
    * **Uso:** Para ejecutar la simulación, simplemente abre Octave y ejecuta `main_simulador_ber`.

### Fragmento de Código (`main_simulador_ber.m`):

```octave
% main_simulador_ber.m
clc;
clear;

% 1. Parámetros de la simulación
num_bits_fuente = 5 * 10^6; % 5 Millones de bits
SNR_dB_range = -5:1:20; % Rango de SNR en dB
% ... (resto del código del simulador, incluyendo la definición de modulaciones,
% los bucles de simulación, y el código de graficación) ...
