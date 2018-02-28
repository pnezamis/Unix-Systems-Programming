// Name of program mainreturn.cpp
#include <iostream>
using namespace std;
 
int main(int argc, char* argv[])
{
    double curr = atof(argv[1]);
    double buy = atof(argv[2]);
    double shares = atof(argv[3]);

    double net = curr - buy;
    
    double ret = net * shares;
    
    cout << ret;
    
   return 0;
}
