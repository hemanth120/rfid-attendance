#include <SPI.h>
#include <MFRC522.h>
#include <WiFi.h>
#include <PubSubClient.h>

// Define pins for RC522
#define SS_PIN 21
#define RST_PIN 22

// Initialize RFID and WiFi credentials
MFRC522 rfid(SS_PIN, RST_PIN);
const char* ssid = "IOT";
const char* password = "12345678";
const char* mqtt_server = "192.168.0.7";  // Your MQTT broker IP

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  Serial.begin(115200);  // Start the serial communication
  SPI.begin();  // Init SPI bus
  rfid.PCD_Init();  // Init RC522 RFID reader

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  // Set MQTT broker and connect
  client.setServer(mqtt_server, 1883);
  reconnect();  // Ensure connection to MQTT broker
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Connecting to MQTT broker...");
    if (client.connect("ESP32Client")) {
      Serial.println("connected");
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // Check for RFID card
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) {
    return;
  }

  // Read RFID UID
  String rfidTag = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    rfidTag += String(rfid.uid.uidByte[i], HEX);
  }

  // Print RFID tag to Serial Monitor
  Serial.print("RFID Tag UID: ");
  Serial.println(rfidTag);

  // Send the RFID UID to the MQTT broker
  if (client.connected()) {
    client.publish("rfid/data", rfidTag.c_str());
  }

  delay(1000);  // Delay to prevent multiple readings
}