#include "mini_string.h"
#include "mini_stdlib.h"
int main ()
{
  unsigned long long a;
  if (! (a = 0xfedcba9876543210ULL))
    abort ();
  exit (0);
}
