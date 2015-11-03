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
typedef struct st_728 {
char titulo[50];
int id;
} st_728;
st_728 livro1, livro2;
typedef struct st_121 {
char marca[35];
char modelo[50];
} st_121;
st_121 carro;

printf("Escreva seu nome:\n");
scanf("%s",  nome);
printf("Entre com a quantidade de notas (max 100):");
scanf("%d", &quant);
if (quant >= 1 && quant <= 100) {
for (i = 1; i <= quant; i+=1) {
do {
printf("Entre com a nota ");
printf("%d", i);
printf(": \n");
scanf("%f", &notas[i]);
if (!(notas[i] >= 0 && notas[i] <= 10)) {
printf("nota incorreta!\n");
}
} while (!(notas[i] >= 0 && notas[i] <= 10));
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
printf("\nmedia: [");
printf("%f", media);
printf("]\n\n");
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
