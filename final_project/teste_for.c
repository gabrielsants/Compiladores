#include <stdio.h>

float value = 400;
float res;

struct {
	int a;
} exemplo;

float square_root() {
    float recorre = value;

    for (int i = 0; i < 10; i++) {
        recorre = recorre / 2 + value/(2 * recorre);
    }

    return recorre;
}

int main() {
	res = square_root();
    
    if (value != 0 || value == 400) {
        return 0;

    } 
    else {
        return 1;
    }
}