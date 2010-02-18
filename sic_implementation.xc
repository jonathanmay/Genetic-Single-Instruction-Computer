#include <stdio.h>

#define MEM_SIZE 1000
#define INSTR_SIZE 300
#define DATA_START 2
#define PROG_END 4444
#define DATA_END 5555
#define EXE_PROG 6666
#define MEM_REQ_END 7777

int memory[MEM_SIZE];
int instructions[INSTR_SIZE];

void feeder(chanend a);
void sic(chanend a);

int main() {

 chan a;

 memory[0]=0; // Initialize location 0 with constant 0
 memory[1]=1; // Initialize location 1 with constant 1

 par {
  feeder(a);
  sic(a);
 }

}

void sic(chanend a) {
 // Receive a program over channel
 // Copy instructions into instruction memory

 // Place any initial memory values (program variables)

 int i=0;
 int end=0;

 int temp_var=0;

 int instr=0;
 while (temp_var!=PROG_END) {
  a :> temp_var;
  if (temp_var!=PROG_END) instructions[instr] = temp_var;
  instr++;
 }

 instr=DATA_START;
 while (temp_var!=DATA_END) {
  a :> temp_var;
  if (temp_var!=DATA_END) memory[instr]=temp_var;
  instr++;
 }

 while (temp_var!=EXE_PROG) {
  a :> temp_var;
 }

 while (end==0) {
  memory[instructions[i]]=memory[instructions[i]]-memory[instructions[i+1]];
  if (memory[instructions[i]]<0) {
   i=instructions[i+2];
  } else {
   i = i+3;
  }
  if ((instructions[i]==0)&(instructions[i+1]==0)&(instructions[i+2]==0)) {
   end=1;
  }
 }

 while (temp_var!=MEM_REQ_END) {
  a :> temp_var;
  if (temp_var!=MEM_REQ_END) a <: memory[temp_var];
 }

}

void feeder(chanend feeder_channel) {

 // This program multiplies a by b and receives back the result
 int a=10;
 int b=3;
 int c_result;

 //start: sbn temp, temp, .+1    # Sets temp to zero
 feeder_channel <: 5;
 feeder_channel <: 5;
 feeder_channel <: 0;

 //loop:  sbn b, one, done       # Decrease b by one, branch if it was zero
 feeder_channel <: 2;
 feeder_channel <: 1;
 feeder_channel <: 9;

 //sbn temp, a, loop      # Subtract a from temp and loop back
 feeder_channel <: 5;
 feeder_channel <: 3;
 feeder_channel <: 3;
 
 //done:  sbn c, c, .+1          # Set c to zero
 feeder_channel <: 4;
 feeder_channel <: 4;
 feeder_channel <: 0;

 //sbn c, temp, .+1       # Set C to product
 feeder_channel <: 4;
 feeder_channel <: 5;
 feeder_channel <: 0;

 feeder_channel <: PROG_END;

 feeder_channel <: a;
 feeder_channel <: b;
 feeder_channel <: DATA_END;

 feeder_channel <: EXE_PROG;

 // Request particular memory locations
 feeder_channel <: 4;
 feeder_channel :> c_result;
 feeder_channel <: MEM_REQ_END;

 printf("%i\n", c_result);

}
