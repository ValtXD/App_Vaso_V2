# PlantCare App

Aplicativo Flutter para monitoramento e controle remoto de plantas inteligentes.  
Integra-se com ESP32 via Wi-Fi para:
- Ler sensores de **umidade do solo** e **luminosidade**.
- Controlar **bomba de água** e **lâmpada** remotamente.
- Exibir histórico de leituras a cada 5 minutos.
- Enviar notificações locais quando a planta precisa de atenção.

---

## Funcionalidades
- Interface moderna em Flutter.
- Leituras em tempo real dos sensores.
- Histórico gráfico (umidade e luz).
- Botões para ligar/desligar bomba e lâmpada.
- Alternância entre **modo automático** e **manual**.
- Notificações locais no celular.

---

## Requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0).
- Android Studio ou VS Code com suporte a Flutter.
- Dispositivo Android ou emulador.
- ESP32 com firmware fornecido neste repositório (`cod_vaso.ino`).

---

## Instalação

1. Clone este repositório:
   ```bash
   git clone https://github.com/seuusuario/plantcare.git
   cd plantcare

## Configuração

1. Abra o arquivo cod_vaso.ino no Arduino IDE.

2. Substitua:
const char* WIFI_SSID = "NOME_DA_SUA_REDE";
const char* WIFI_PASS = "SENHA_DA_SUA_REDE";

Faça o upload para o ESP32.

No Serial Monitor, copie o IP atribuído (ex.: 192.168.0.50).

No Flutter, edite sensor_provider.dart e configure:
final SensorServiceHttp _service = SensorServiceHttp('http://192.168.0.50');

## Endpoints

Endpoints disponíveis no ESP32
GET /status → retorna JSON com sensores e estados.

POST /pump?state=on|off → liga/desliga bomba.

POST /lamp?state=on|off → liga/desliga lâmpada.

POST /mode?auto=true|false → alterna modo automático/manual.

## AVISO

Futuras Implementações com IA -> Identificação de Plantas 