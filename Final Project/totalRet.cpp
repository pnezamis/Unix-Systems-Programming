// Name of program mainreturn.cpp
#include <iostream>
using namespace std;

int main(int argc, char* argv[])
{
    double ret = atof(argv[1]);
    double tot  = atof(argv[2]);

    cout << ret+tot;

   return 0;
}
