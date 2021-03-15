#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>

//Change based on user's config. Currently have to hardcode
#define WIFINAME "3logytech2.4"   
#define WIFIPASSWORD "3logytech1928"
#define BAUTRATE 9600
#define FIREBASE_HOST "https://smart-weighing-scale.firebaseio.com" 
#define FIREBASE_AUTH "lKnRDHY6WdkVLT0EojGSOh46QclI7JR8R1LMcuTz"
#define FIREBASE_COMMAND_ADDRESS "/Exchange/Command"

WiFiClientSecure client;
FirebaseData firebaseData;

unsigned long previousTime;
char firebaseWriteAddress[50];
char firebaseReadAddress[50];
char previousMessage[18];

bool maxWRead;
bool minWRead;
bool capRead;
bool instructedToConnectWifi;

// ESP8266 has very limited memory and would throw errors
// Memory optimization is needed hence no std::strings are used

void readSpecs(){
  // read product details stored in firebase database

  // creates a temperorary char array to represent firebase address 
  char tempAddress[90];
  strcpy(tempAddress,firebaseReadAddress);

  // read max weight
  if (!maxWRead){
    strcat(tempAddress,"/Product/MaxW");
    if (Firebase.get(firebaseData,tempAddress)){
      if (firebaseData.dataType() == "string"){
        char maxWMessage[10] = "max:";
        strcat(maxWMessage,firebaseData.stringData().c_str());
        Serial.println(maxWMessage);
        maxWRead = true;
      }
    }
  }

  strcpy(tempAddress,firebaseReadAddress);

  // read min weight
  if(!minWRead){
    strcat(tempAddress,"/Product/MinW");
    if (Firebase.get(firebaseData,tempAddress)){
      if (firebaseData.dataType() == "string"){
        char minWMessage[10] = "min:";
        strcat(minWMessage,firebaseData.stringData().c_str());
        Serial.println(minWMessage);
        minWRead = true;
      }
    }
  }

  strcpy(tempAddress,firebaseReadAddress);

  // read capacity
  if (!capRead){
    strcat(tempAddress,"/Product/Capacity");
    if (Firebase.get(firebaseData,tempAddress)){
      if (firebaseData.dataType() == "string"){
        char capMessage[10] = "cap:";
        strcat(capMessage,firebaseData.stringData().c_str());
        Serial.println(capMessage);
        minWRead = true;
      }
    }
  }
}

void readDisplayPref(){

  // read mode of display on scale. Either in Weight, Percentage or Volume
  char displayAddress[90];
  strcpy(displayAddress,firebaseReadAddress);
  strcat(displayAddress,"/Display");
  
  if (Firebase.get(firebaseData,displayAddress)){
    
    if (firebaseData.dataType() == "string"){
      
      char displayMessage[20] = "dsp:";
      strcat(displayMessage, firebaseData.stringData().c_str());
      
      byte counter = 0;
      for (byte i =0; i<strlen(displayMessage); i++){
        // Only send message to Arduino if user pref has changed to prevent congestion in Serial messages
        if (previousMessage[i] != displayMessage[i]){
          counter++;
          previousMessage[i] = displayMessage[i];
        }
      }
      if (counter != 0){
        Serial.println(displayMessage);
      }
    }
  }
}

void initialReadFireBase(){
  
  Firebase.begin(FIREBASE_HOST,FIREBASE_AUTH);
  
  if(Firebase.get(firebaseData, FIREBASE_COMMAND_ADDRESS)){
    if (firebaseData.dataType() == "string"){
      
      char data[30];
      strcpy(data,firebaseData.stringData().c_str());
      if (strncmp(data, "read", 4) == 0){ 
        strcpy(firebaseReadAddress, "/UserData/");
        strncat(firebaseReadAddress, data +4,20);
        readSpecs();

        // sets the write address for updating weight onto firebase later
        strcpy(firebaseWriteAddress,"/UserData/");
        strncat(firebaseWriteAddress, data +4,20);
        strcat(firebaseWriteAddress,"/Weight");
      }
    }
  }
}

void connectWifi(){

  WiFi.begin(WIFINAME, WIFIPASSWORD);
  instructedToConnectWifi = true;
  
  if (WiFi.status() == WL_CONNECTED){
    Serial.print("WiFi Connected!\n");
  }

  else {
    Serial.print("Connecting. to Wifi...\n");
  }
}

void readArd(){
// function to read Serial inputs from arduino
  String message = Serial.readStringUntil('\n');
    if (message == "Reset"){
      //
      initialiseBools();
      connectWifi();
    }
    else{
      // sends weight to firebase
      Firebase.setString(firebaseData, firebaseWriteAddress,message);
    }
}

void initialiseBools(){
  
  maxWRead = false;
  minWRead = false;
  capRead = false;
  instructedToConnectWifi = false;
  strcpy(previousMessage,""); // resets previousMessage so esp will resend data to arduino
}

void setup() {
  Serial.begin(BAUTRATE);
  previousTime = millis();
  initialiseBools();
}
 
void loop() {

  if (Serial.available()){
    readArd();
  }
  
  if (instructedToConnectWifi){
      
    unsigned long currentTime = millis();
    if (WiFi.status() != WL_CONNECTED){
      if (currentTime - previousTime > 5000){
        // cycles every 5 sec so there is time for connection
        connectWifi();
        previousTime = currentTime;
      }
    }
    
    else{
      if (currentTime - previousTime >2000){
        
        if (!minWRead || !maxWRead || !capRead){
          // stop once product details 
          initialReadFireBase(); 
        }
        else {
          // if user changes the display preference via phone app, it will be noted
          readDisplayPref();
        }
        previousTime = currentTime;
      }
    }
  }
}
