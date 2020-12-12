#include <stdio.h>

// @Author : Gabriel Santos - UFG JATAI

enum STATES {Q1 , Q2, Q3};

enum STATES state = Q1;

void transition(char element) {
    
    switch (state) {
        case Q1:
            switch (element) {
                case 'a'...'z':
                case 'A'...'Z':
                case '_':
                    state = Q2;
                    break;
                //else as default
                default:
                    //rejected
                    state = Q3;
            }
            break;

        case Q2:
            switch (element) {
                case 'a'...'z':
                case 'A'...'Z':
                case '_':
                case '0'...'9':
                    state = Q2;
                    break;
                default:
                    state = Q3;
            }
            break;

        case Q3:
            break;
        default:
            break;
    }
}

int main() {
    int size = 0;
    char element;

    printf("../ > > > Running! Wait for it ...\n\n");
    printf("*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n");

    while(scanf("%c",&element) > 0) {
        switch (element) {
        case ' ':
        case '/t':
        case '/r':
        case '/n':
        case ',':
        case '{':
        case '}':
        case ';':
        case '(':
        case ')':
        case '\"':
        case '%':
        case '\'':
        case '&':
        case '/':
        case '+':
        case ':':
        case '#':
        case '<':
        case '>':
        case '@':
        case '!':
            if( size > 0) {
                if(state == Q2) {
                    printf("\033[1;32m Recognized\n");
                }
                else
                    printf("\033[1;31m Not recognized\n");
                printf("\033[0m\n");
            }

            state = Q1;
            size = 0;
            break;
        default:
            size++;
            printf("%c",element);
            transition(element);
        }
    }

    printf("*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n");
	printf("Thanks for using this script! I hope you have enjoyed this trip!\n ** Made by Gabriel Santos\n\n");

    return 1;
}