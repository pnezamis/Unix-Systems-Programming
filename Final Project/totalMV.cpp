// Name of program mainreturn.cpp
#include <iostream>
using namespace std;

int main(int argc, char* argv[])
{
    double total = atof(argv[1]);
    double curr  = atof(argv[2]);
    double shares = atof(argv[3]);

    double mv = curr * shares;



    cout << total + mv;

   return 0;
}
                                                                
           
