
//  Pinouts

const int RELAY_1 = 6;
const int RELAY_2 = 3;
const int RELAY_3 = 4;
const int RELAY_4 = 5;
const int LED_PIN = 13;

int shutterTime = 400;
const long MAIN_LASER_TIME = 309800;   // THIS IS THE TIME IT TAKES TO FINISH THE MAIN LASER ROUTINE
int COUNTER = 80;
const int NUM_COASTERS = 200;
long picMillis;  //delay until pic time
int incomingByte = 0;   // for incoming serial data
bool picFlag = false;

void setup() {
        Serial.begin(115200);    
		pinMode(RELAY_1, OUTPUT);
		pinMode(RELAY_2, OUTPUT);
		pinMode(RELAY_3, OUTPUT);
		pinMode(RELAY_4, OUTPUT);
		pinMode(LED_PIN, OUTPUT);
		digitalWrite(RELAY_1, HIGH);
		digitalWrite(RELAY_2, HIGH);
		digitalWrite(RELAY_3, HIGH);
		digitalWrite(RELAY_4, HIGH);
		digitalWrite(LED_PIN,LOW);
}

void loop() {

        // send data only when you receive data:
        if (Serial.available() > 0) {
                // read the incoming byte:
                incomingByte = Serial.read();

                if(incomingByte == 'R'){
					resetCounter();
					Serial.print("Shutter Counter = ");
					Serial.println(COUNTER);
				}
                else if(incomingByte == 'A'){
					takePic();
				} 
                else if (incomingByte == 'D'){
					increment();
					
					takeDelayedPic();
				}
				else if (incomingByte == 'T'){
					testRelays();
				}
                else{
					Serial.println(incomingByte);
				}
        }
		unsigned long currentMillis = millis();
		if (picFlag == true && currentMillis >= picMillis){
			takeBothPic();
			picFlag = false;
		}
		if (picFlag == true && millis()%500 > 250){
			digitalWrite(LED_PIN, HIGH);
		} else{
			digitalWrite(LED_PIN, LOW);
		}
}


void takePic(){
	digitalWrite(RELAY_3, LOW);
	digitalWrite(RELAY_4, LOW);
	digitalWrite(LED_PIN, HIGH);
	delay(shutterTime);
	digitalWrite(RELAY_3, HIGH);
	digitalWrite(RELAY_4, HIGH);
	digitalWrite(LED_PIN, LOW);
	delay(50);
	digitalWrite(LED_PIN, HIGH);
	delay(50);
	digitalWrite(LED_PIN, LOW);
	delay(50);
	digitalWrite(LED_PIN, HIGH);
	delay(50);
	digitalWrite(LED_PIN, LOW);
	delay(50);
	digitalWrite(LED_PIN, HIGH);
	delay(50);
	digitalWrite(LED_PIN, LOW);
}

void takeBothPic(){
	//digitalWrite(RELAY_1, LOW);
	digitalWrite(RELAY_2, LOW);
	digitalWrite(RELAY_3, LOW);
	digitalWrite(RELAY_4, LOW);
	digitalWrite(LED_PIN, HIGH);
	delay(shutterTime);
	//digitalWrite(RELAY_1, HIGH);
	
	digitalWrite(RELAY_3, HIGH);
	digitalWrite(RELAY_4, HIGH);
	digitalWrite(LED_PIN, LOW);
	delay(50);
	digitalWrite(LED_PIN, HIGH);
	delay(50);
	digitalWrite(LED_PIN, LOW);
	delay(50);
	digitalWrite(LED_PIN, HIGH);
	delay(50);
	digitalWrite(LED_PIN, LOW);
	delay(50);
	digitalWrite(LED_PIN, HIGH);
	delay(50);
	digitalWrite(LED_PIN, LOW);
	digitalWrite(RELAY_2, HIGH);
}

int increment(){
	COUNTER = COUNTER+1;
	Serial.print("SHUTTER COUNTER = ");
	Serial.println(COUNTER);
	return(COUNTER);
}

int resetCounter(){
	COUNTER = 0;
	return(COUNTER);
}

int takeDelayedPic(){
	long wait = (MAIN_LASER_TIME/NUM_COASTERS*COUNTER);
	Serial.println(wait);
	unsigned long currentMillis = millis();
	picMillis = currentMillis + wait;
	picFlag = true;
}

void testRelays(){
	Serial.println("Testing Relays");
	digitalWrite(RELAY_1, LOW);
	delay(500);
	digitalWrite(RELAY_1, HIGH);
	delay(500);
	digitalWrite(RELAY_2, LOW);
	delay(500);
	digitalWrite(RELAY_2, HIGH);
	delay(500);
	digitalWrite(RELAY_3, LOW);
	delay(500);
	digitalWrite(RELAY_3, HIGH);
	delay(500);
	digitalWrite(RELAY_4, LOW);
	delay(500);
	digitalWrite(RELAY_4, HIGH);
	delay(500);
}


 



