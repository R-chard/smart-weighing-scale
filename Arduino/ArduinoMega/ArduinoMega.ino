#include "HX711.h"
#include <LiquidCrystal.h>

//Location of pins on Arduino mega for HX711
#define DAT A0  
#define CLK A1
#define TX 12
#define RX 13

//Location of pins on Arduino Mega for LCD
#define RS 8
#define E 9
#define D4 2
#define D5 3
#define D6 4
#define D7 5

// Baud rate 9600 because of loose cables. Arduino Mega can support 115200
#define ARDUINOM_BR 9600
#define ESP_BR 9600

#define CALIBRATIONFACTOR -54835 // To be tested again with new hardware

LiquidCrystal lcd(RS,E,D4,D5,D6,D7);
HX711 scale;

float minWeight; // Weight of empty object
float maxWeight; // Weight of full object
float capacity; //  Liquid capacity of object
String displayPref; // Either "Weight", "Volume" or "Percent"
bool specsReceived; // true if all info above received

unsigned long previousTime;

void checkSpecs(){
  if (maxWeight != NULL && minWeight != NULL && capacity != NULL && displayPref != NULL){
    specsReceived = true;
    Serial.print("All product details received");
  }
}

void readESP(){
  // min weight, max weight and item capacity is sent to arduino from esp
  String message = Serial3.readStringUntil('\n');
  
  if (message.substring(0,3) == "min"){
    minWeight = message.substring(4).toFloat();
    Serial.println("Min weight obtained");
  }

  else if (message.substring(0,3) == "max"){
    maxWeight = message.substring(4).toFloat();
    Serial.println("Max weight obtained");
  }

  else if (message.substring(0,3) == "cap"){
    capacity = message.substring(4).toFloat();
    Serial.println("Capacity obtained");
  }

  else if (message.substring(0,3) == "dsp"){
    displayPref = message.substring(4);
    Serial.println("Display mode obtained");
    displayPref.remove(displayPref.length()-1,1);
    // remove carriage return char
    if (!specsReceived){
      checkSpecs();
    }
  }
 
  else{
    Serial.println(message);
    if (message.startsWith("C") || message.startsWith("W")){
      // only other messages now are "Connecting to Wifi" and "Wifi Connected"
      // Included this code to prevent rubbish printed by ESP if it restarts
    
      if (message.length() <= 16){
        sendLCD(message,0);
      }
      else {
        byte breakpoint = message.indexOf(". ");
        message = message.substring(0,breakpoint) + message.substring(breakpoint+1); 
        sendLCD(message,breakpoint);
      }
    }
  }
}

void sendLCD(String message, byte breakPoint){
  // function used to centralise and print message on LCD
  
  lcd.clear();
  message.replace("\n","");

  // centralise message on LCD
  if (breakPoint == 0){
    int firstChar = int((16 - message.length())/2);
    lcd.setCursor(firstChar,0);
    lcd.print(message);
  }
  
  else{
    int row1firstChar = int((16 - breakPoint)/2);
    lcd.setCursor(row1firstChar,0);
    lcd.print(message.substring(0,breakPoint));
    int row2firstChar = int((16-message.length()+breakPoint)/2) +1;
    lcd.setCursor(row2firstChar,1);
    lcd.print(message.substring(breakPoint+1));
  }
}

void tareScale(){
  
  scale.wait_ready(1000);
  scale.read_average(20);   //Only tare when reading has stabilised
  scale.tare(25); 
  scale.set_scale(CALIBRATIONFACTOR);
  
  Serial.println("\nTARE Complete");
  sendLCD("TARE Complete",0);
  delay(1500);
  sendLCD("Place Weight on Scale",12);

  Serial3.print("Reset");
  // Sends the command for esp to start wifi connection
}

void readScale(){
  
  float weight = scale.get_units(30);// return value after tare
  
  if( -0.01 < weight && weight < 0.00){
    // remove negative signs for slight differences
    weight = -weight;
  }
  
  String weightWithUnits = String(weight) + " kg";
  
  int percent = int(((weight - minWeight)*100/(maxWeight - minWeight)));
  String percentWithUnits = String(percent) + " %";

  int volume = (percent * capacity)/100;
  String volumeWithUnits = String(volume) + " ml";

  if (weight< minWeight){
    Serial.println("Place weight onto scale");
    sendLCD("Place weight onto scale",12);
  }

  else {
    if (displayPref == "Weight"){
    Serial.println(weightWithUnits);
    sendLCD(weightWithUnits,0);
  }
  
  else if (displayPref == "Percentage"){
    Serial.println(percentWithUnits);
    sendLCD(percentWithUnits,0);
  }

  else if (displayPref == "Volume"){
    Serial.println(volumeWithUnits);
    sendLCD(volumeWithUnits,0);
  }

  Serial3.print(String(weight)); // Weight is stored onto firebase to update phone app
  }
}

void setup() {
  // initiate connection with all other devices
  Serial.begin(ARDUINOM_BR);
  Serial3.begin(ESP_BR);
  scale.begin(DAT,CLK);
  lcd.begin(16,2);// Dimensions of LCD I am using
  
  specsReceived = false;
  
  tareScale(); 
  previousTime = millis();
                 
}

void loop() {
  // put your main code here, to run repeatedly:
  
  if (Serial3.available()){
    readESP();
  }
  
  if (specsReceived){
    unsigned long currentTime = millis();
    if (currentTime - previousTime >1000){
    // only readScale when calibration is done
      readScale();
      previousTime = currentTime;
    }
   }
  
}
