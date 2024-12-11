#include <stdio.h>

/* prototipo para la rutina ensamblador */
int det(int a, int b, int c, int d) __attribute__((cdecl));

int main(void)
{
    int a, b, c, d, r;

    printf("Ingrese un numero para la posicion a en: a*b-c*d: ");
    scanf("%d", &a);
    printf("Ingrese un numero para la posicion b en: a*b-c*d: ");
    scanf("%d", &b);
    printf("Ingrese un numero para la posicion c en: a*b-c*d: ");
    scanf("%d", &c);
    printf("Ingrese un numero para la posicion d en: a*b-c*d: ");
    scanf("%d", &d);
    r = det(a, b, c, d);
    printf("El resultado de %d*%d-%d*%d = %d\n", a, b, c, d, r);
    return 0;
}
