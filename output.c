#include <stdio.h>
#include <stdlib.h>

#define RESTO(x,y) (x%y)
#define ABS(x) (x >= 0 ? x:-x)
#define TRUNCA(x) ((int) (x/1))

double temp;
temp = 0;
for (i = 1; i <= tamanho; i+=1) {
temp = temp+vetor[i];
}
media = temp/tamanho;
int main (int argc, char* argv[]) {
int i, quant;
double notas[100];
double media;
char nome[100];
printf("Entre com a quantidade de notas (max 100):");
printf("a quantidade sera: ");
printf("%d", quant);
if (quant >= 1 && quant <= 100) {
for (i = 1; i <= quant; i+=1) {
}
media = calculaMedia(notas,quant);
if (media >= 6) {
printf("ALUNO APROVADO!");
} else {
printf("ALUNO REPROVADO!");
}}tchau = 1;
return 0;
}
