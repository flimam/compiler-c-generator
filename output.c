#include <stdio.h>
#include <stdlib.h>

#define RESTO(x,y) (x%y)
#define ABS(x) (x >= 0 ? x:-x)
#define TRUNCA(x) ((int) (x/1))

float calculamedia(float n1, float n2) {
media = (n1+n2)/2;
return media;
}

void arruma(char letra, int idade) {
printf("A letra ");
printf("%?", letra);
printf(" possui ");
printf("%?", idade);
printf(" anos.\n");
}

int main (int argc, char* argv[]) {
i, quant;
media, temp, notas[100];
nome[200][50][10][20];
notas2[100], outra[2][3], outra2, outra3[2];
nota;
typedef struct gabriel {
ii;
quanti;
} gabriel;
printf("Entre com a quantidade de notas (max 100):");
scanf("%d", &quant);
if (quant >= 1 && quant <= 100) {
printf("Escreva seu nome:\n");
scanf("%s",  nome);
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
if (media >= TRUNCA(6)) {
printf("ALUNO APROVADO!\n");
} else {
printf("ALUNO REPROVADO!\n");
}
printf("Fim do acesso do usuário ");
printf("%s", nome);
printf(".\n");
} else {
printf("Quantidade de alunos invalida!!");
}
return 0;
}
