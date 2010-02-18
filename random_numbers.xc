#include <stdio.h>
#include <xs1.h>

void requestor(chanend a);
void random_number_gen(chanend a);
int mod(int innum);

int main() {

 chan a; 

 par {
  random_number_gen(a);
  requestor(a);
 }

} 

void requestor(chanend a) {

 int num_gen;

 while (1) {
  a :> num_gen;
  printf("%i\n",mod(num_gen)/(1 << 28));
 }

}

int mod(int innum) {
 return (innum < 0) ? -innum : innum;
}

void random_number_gen(chanend a) {

 unsigned int random = 1; // Seed
 while (1) {
  crc32(random,0xffffffff,0xEDB88320);
  a <: random;
 }

}
