# VoiceLogic – Sistema de Seguridad por Reconocimiento de Voz

VoiceLogic es un prototipo desarrollado por el equipo **Robologic** con el objetivo de diseñar un sistema de seguridad accesible para personas con discapacidad visual o motriz. El sistema utiliza el microcontrolador **ATmega16** como unidad principal y emplea algoritmos de reconocimiento de voz para otorgar o denegar acceso, integrando además comunicación con una aplicación móvil.

---

## 🚀 Características principales
- **Reconocimiento de voz en tiempo real** con un promedio de precisión del **70%**.  
- **Microcontrolador ATmega16** para el procesamiento y control principal del sistema.  
- **Extracción de características de audio**: energía, varianza, media absoluta, frecuencia dominante, curtosis, entropía espectral y ZCR.  
- **Clasificación con algoritmo ECOC** (Error-Correcting Output Codes) para distinguir usuarios registrados.  
- **Comunicación con MATLAB** para procesamiento de audio y generación del modelo predictivo.  
- **Módulos de hardware**:  
  - Micrófono MAX9814 para captura de audio.  
  - DFPlayer Mini para reproducción de mensajes de voz.  
  - Pantalla OLED para retroalimentación visual.  
  - Bocinas y potenciómetro para salida y control de volumen.  
  - Módulo Bluetooth para conexión con aplicación móvil.  
- **Interfaz móvil Android** para visualizar resultados y recibir notificaciones de acceso.  
- **Caja de madera cortada en láser** como estructura física del prototipo.  

---

## 🛠️ Materiales principales
- ATmega16  
- DFPlayer Mini  
- Micrófono MAX9814  
- Pantalla OLED  
- Bocina + potenciómetro  
- Módulo Bluetooth HC-05  
- Arduino de apoyo para animaciones gráficas  

---

## 📊 Resultados
- **Precisión alcanzada**: 70% en pruebas con 70 audios por usuario.  
- **Tiempo de muestreo promedio**: 20 segundos (≈8000 muestras).  
- **Costo total del prototipo**: $900 MXN (objetivo inicial: $700).  
- **Limitaciones detectadas**: similitudes entre voces y tiempos de muestreo lentos.  

---

## 🔮 Trabajo a futuro
- Migración a un **sistema embebido 100% independiente** con STM32H745 NUCLEO.  
- Reducción del tiempo de muestreo.  
- Ingreso de nuevos usuarios directamente desde la aplicación móvil.  
- Uso de **TinyML o SVM/KNN locales** para clasificación sin depender de MATLAB.  
- Mejoras en la calidad de captura de audio (12 o 16 bits).  
- Implementación de buffers más grandes y múltiples UART nativos.  

---

## 👥 Autores
- Sofía Estrada Hernández – A01666608  
- Emma Sofía García Montealegre – A01659535  
- Christian Damar Marín Ramírez – A01659334  
- Carolina Pérez Valencia – A01665909  
