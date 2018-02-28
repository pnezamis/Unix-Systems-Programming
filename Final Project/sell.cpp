// Name of program mainreturn.cpp
#include <iostream>
using namespace std;

int main(int argc, char* argv[])
{
    double curr = atof(argv[1]);
    double cash  = atof(argv[2]);
    double shares = atof(argv[3]);

    double mv = curr * shares;



    cout << cash + mv;

   return 0;
}
