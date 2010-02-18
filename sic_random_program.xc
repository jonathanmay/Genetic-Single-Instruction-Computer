#include <stdio.h>
#include <xs1.h>

#define MEM_SIZE 1000
#define INSTR_SIZE 300
#define DATA_START 2
#define PROG_END 4444
#define DATA_END 5555
#define EXE_PROG 6666
#define MEM_REQ_END 7777
#define MAX_CYCLES 100

int memory[MEM_SIZE];
int instructions[INSTR_SIZE];

void feeder(chanend a, chanend b);
void sic(chanend a);
void random_number_gen(chanend a);
int mod(int innum);

int main() {

 chan a,r;

 memory[0]=0; // Initialize location 0 with constant 0
 memory[1]=1; // Initialize location 1 with constant 1

 par {
  feeder(a,r);
  sic(a);
  random_number_gen(r);
 }

}

void sic(chanend a) {
 // Receive a program over channel
 // Copy instructions into instruction memory

 // Place any initial memory values (program variables)

 int i=0;
 int end=0;
 int cycles=0;

 int temp_var=0;

 int instr=0;
 while (temp_var!=PROG_END) {
  a :> temp_var;
  //printf("%i\n",temp_var);
  if (temp_var!=PROG_END) instructions[instr] = temp_var;
  instr++;
 }

 instr=DATA_START;
 while (temp_var!=DATA_END) {
  a :> temp_var;
  //printf("%i\n",temp_var);
  if (temp_var!=DATA_END) memory[instr]=temp_var;
  instr++;
 }

 while (temp_var!=EXE_PROG) {
  a :> temp_var;
 }

 while ((cycles<MAX_CYCLES)&(end==0)) {
  memory[instructions[i]]=memory[instructions[i]]-memory[instructions[i+1]];
  if (memory[instructions[i]]<0) {
   i=instructions[i+2];
  } else {
   i = i+3;
  }
  if ((instructions[i]==0)&(instructions[i+1]==0)&(instructions[i+2]==0)) {
   end=1;
  }
  cycles++;
 }

 while (temp_var!=MEM_REQ_END) {
  a :> temp_var;
  if (temp_var!=MEM_REQ_END) a <: memory[temp_var];
 }

}

void feeder(chanend feeder_channel, chanend random_chan) {

 // This program multiplies a by b and receives back the result
 int a=10;
 int b=3;
 int c_result;

 int instrs=0;
 int temp_in;

 while (instrs<30) {
  random_chan :> temp_in;
  feeder_channel <: mod(temp_in)/(1<<28);
  instrs++;
 }

 feeder_channel <: PROG_END;

 instrs=0;
 while (instrs<5) {
  random_chan :> temp_in;
  feeder_channel <: mod(temp_in)/(1<<28);
  instrs++;
 }

 feeder_channel <: DATA_END;
 feeder_channel <: EXE_PROG;

 // Request particular memory locations
 feeder_channel <: 4;
 feeder_channel :> c_result;
 feeder_channel <: MEM_REQ_END;

 printf("%i\n", c_result);

}

int mod(int innum) {
 return (innum < 0) ? -innum : innum;
}

void random_number_gen(chanend a) {

 unsigned int random = 12; // Seed
 while (1) {
  crc32(random,0xffffffff,0xEDB88320);
  a <: random;
 }

}
