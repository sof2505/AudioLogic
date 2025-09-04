clc;
clear;
close all;

% === ENTRENAMIENTO SOLO SI NO EXISTE ===
if ~isfile("modelo_simple.mat")
    disp(" Entrenando modelo...");

    carpeta = 'AudiosRobologic';
    archivos = dir(fullfile(carpeta, '*.wav'));

    X = [];
    Y = [];

    for i = 1:length(archivos)
        [audio, Fs] = audioread(fullfile(carpeta, archivos(i).name));
        if size(audio, 2) == 2
            audio = mean(audio, 2);
        end
        if isa(audio, 'uint8')
            audio = double(audio);
            audio = (audio - 128) / 128;
        end
        audio = audio - mean(audio);
        if max(abs(audio)) > 0
            audio = audio / max(abs(audio));
        end

        energia = sum(audio.^2) / length(audio);
        varianza = var(audio);
        media_abs = mean(abs(audio));

        nfft = 1024;
        A = abs(fft(audio, nfft));
        A = A(1:nfft/2);
        [~, idx_max] = max(A);
        freq_dominante = (idx_max-1) * (Fs/nfft);

        caracteristicas = [energia, varianza, media_abs, freq_dominante];

        nombre = lower(archivos(i).name);
        if contains(nombre, 'emma')
            Y = [Y; "Emma"];
        elseif contains(nombre, 'caro')
            Y = [Y; "Caro"];
        elseif contains(nombre, 'chris')
            Y = [Y; "Chris"];
        elseif contains(nombre, 'sofi')
            Y = [Y; "Sofi"];
        else
            warning(['Archivo sin etiqueta reconocida: ', archivos(i).name]);
            continue;
        end

        X = [X; caracteristicas];
    end

    if size(X,1) >= 2 && ~isempty(unique(Y))
        modelo = fitcecoc(X, Y);
        save('modelo_simple.mat', 'modelo');
        disp(" Modelo entrenado y guardado. OK");
    else
        error(" Datos insuficientes para entrenar.");
    end

    % Gráfico opcional
    figure;
    labels = unique(Y);
    colors = lines(numel(labels));
    hold on;
    for i = 1:numel(labels)
        idx = Y == labels(i);
        scatter3(X(idx,1), X(idx,2), X(idx,4), 80, colors(i,:), 'filled', 'DisplayName', labels(i));
    end
    xlabel('Energía');
    ylabel('Varianza');
    zlabel('Frecuencia dominante');
    title('Voces por características');
    legend show;
    grid on;
    view(135, 25);
end

% === COMUNICACIÓN TTL Y RECONOCIMIENTO ===
disp("🔌 Conectando al puerto serial...");
delete(instrfindall)
s = serialport("COM5", 9600);
flush(s);

load('modelo_simple.mat', 'modelo');

while true
    disp(" Waiting Botón...");

    timeout = tic;
    while s.NumBytesAvailable < 3
        if toc(timeout) > 60
            warning(" Tiempo excedido sin datos.");
            break;
        end
        pause(0.01);
    end

    if s.NumBytesAvailable < 3
        continue;
    end

    disp("🎙 Capturando audio...");

    Nmax = 8000;
    audio = zeros(1, Nmax);
    idx = 1;

    while idx <= Nmax
        if s.NumBytesAvailable >= 3
            sync = read(s, 1, "uint8");
            if sync == 170
                low = read(s, 1, "uint8");
                high = read(s, 1, "uint8");
                value = double(low) + bitshift(double(high), 8);

                if value ~= 65535
                    audio(idx) = value;
                    idx = idx + 1;
                else
                    disp(" Fin de transmisión.");
                    break;
                end

                if mod(idx, 1000) == 0
                    fprintf(" Muestras leídas: %d\n", idx);
                end
            end
        end
    end

    % === NORMALIZAR Y GUARDAR ===
    a_norm = (audio - 512) / 512;
    a_norm = a_norm - mean(a_norm);
    a_norm = a_norm / max(abs(a_norm));
    a_norm = a_norm * 0.8;

    fs = 1600;
    filename = sprintf("grabacion_%s.wav", datestr(now, 'HHMMSS'));
    audiowrite(filename, a_norm, fs);
    fprintf("Saved file. Guardado: %s\n", filename);

    % === EXTRAER CARACTERÍSTICAS ===
    energia = sum(a_norm.^2) / length(a_norm);
    varianza = var(a_norm);
    media_abs = mean(abs(a_norm));

    nfft = 1024;
    A = abs(fft(a_norm, nfft));
    A = A(1:nfft/2);
    [~, idx_max] = max(A);
    freq_dominante = (idx_max-1) * (fs/nfft);

    caracteristicas = [energia, varianza, media_abs, freq_dominante];

    % === VERIFICACIÓN DE ENERGÍA MÍNIMA ===
    umbral_energia = 0.001;  % Ajustable según pruebas
    if energia < umbral_energia
        disp("⚠ Audio demasiado débil o sin señal. Reproduciendo mensaje de error...");
        indice = 5;
        write(s, uint8(indice), "uint8");
        fprintf("📤 Índice %d enviado al microcontrolador.\n", indice);
        continue;
    end

    % === PREDICCIÓN ===
    etiqueta = predict(modelo, caracteristicas);
    disp(['✅ Voz reconocida: ', etiqueta]);

    % === ENVIAR ÍNDICE CORRESPONDIENTE O DE ERROR ===
    nombres = ["Emma", "Caro", "Chris", "Sofi"];
    indice = find(nombres == etiqueta);

    if isempty(indice)
        disp("❌ Usuario no reconocido. Reproduciendo audio de error...");
        indice = 5;
    else
        disp(" Reproduciendo audio correspondiente...");
    end

    write(s, uint8(indice), "uint8");
    fprintf(" Índice %d enviado al microcontrolador.\n", indice);

    % === VISUALIZAR ===
    plot(a_norm);
    title("Audio recibido");
    xlabel("Muestra");
    ylabel("Amplitud");
    pause(1);
end