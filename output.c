#include <stdio.h>
#include <stdlib.h>

#define RESTO(x,y) (x%y)
#define ABS(x) (x >= 0 ? x:-x)
#define TRUNCA(x) ((int) (x/1))

void surpresa(){
float valor;
int oi;
return;
}

int main (int argc, char* argv[]) {
int i, quant;
float media, temp, notas[100];
printf("Entre com a quantidade de notas (max 100):");
scanf("%d", &quant);
if (quant >= 1 && quant <= 100) {
for (i = 1; i <= quant; i+=1) {
printf("Entre com a nota ");
printf("%d", i);
printf(": \n");
scanf("%f", &notas[i]);
}
printf("Lista das Notas:\n");
i = 1;
while (i <= quant) {
printf("Nota ");
printf("%d", i);
printf(": ");
printf("%f", notas[i]);
printf("\n");
i = i+1;
}
temp = 0;
for (i = 1; i <= quant; i+=1) {
temp = temp+notas[i];
}
media = temp/quant;
if (media >= 6) {
printf("ALUNO APROVADO!\n");
} else {
printf("ALUNO REPROVADO!\n");
}
} else {
printf("Quantidade de alunos invalida!!");
}
return 0;
}
