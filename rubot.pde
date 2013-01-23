#include <AFMotor.h> // Adafruit Motor shield library

AF_DCMotor motors[] = {AF_DCMotor(1), AF_DCMotor(2), AF_DCMotor(3), AF_DCMotor(4)};
int i = 0;

void setup() {
  Serial.begin(9600);
  Serial.println("Motor test!\n");
  for(i=0;i<4;i++) {
    motors[i].run(RELEASE);
  }
}

void loop() {
  uint8_t motor;
  uint8_t direction;
  uint8_t speed;
  while (Serial.available() > 2) {
    motor     = Serial.read();
    direction = Serial.read();
    speed     = Serial.read();
    if(motor > 0 && motor < 5) {
      //FORWARD=1; BACKWARD=2; BRAKE=3; RELEASE=4
      if(direction < 1 || direction > 4) {
        direction = 4;
      }
      //Serial.print("OK");
      motors[motor-1].setSpeed(speed);
      motors[motor-1].run(direction);
    }
  }
}