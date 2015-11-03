#include <stdio.h>
#include <stdlib.h>

#define RESTO(x,y) (x%y)
#define ABS(x) (x >= 0 ? x:-x)
#define TRUNCA(x) ((int) (x/1))

float calculamedia(char n1, float n2) {
float resultado;
resultado = (n1+n2)/2;
return resultado;
}

void exemplo(char letra, int idade) {
printf("A letra ");
printf("%c", letra);
printf(" possui ");
printf("%d", idade);
printf(" anos.\n");
}

int main (int argc, char* argv[]) {

int i, quant;
float media, temp, notas[100];
char nome[200];
typedef struct st_528 {
int ii;
int quanti;
} st_528;
st_528 maria, gabriel;
typedef struct st_350 {
float aa;
char bb;
} st_350;
st_350 joao;
typedef struct st_371 {
float cc;
char dd;
} st_371;
st_371 debora;
typedef struct st_551 {
float ee;
char ff;
} st_551;
st_551 felipe;

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
