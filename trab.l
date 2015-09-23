%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAM_IDENT 100

#include "trab.tab.h"

typedef struct std {
	char lexema[TAM_IDENT];	
	struct std *prox;
} IDENT;

IDENT *lista = NULL;
int insereLista(IDENT**, char*);

%}

%option yylineno

delim		[ \t\n]+
identificador 	[a-zA-Z][a-zA-Z0-9]{0,31}
num_inteiro	[0-9]+
num_real	[0-9]+,[0-9]+
const_lit	(\")[^\n]*(\")
comment		\/\/[^\n]*

%%

{delim} { /* sem ação para delimitadores. */ }
{comment} { /* sem ação para comentários simples. */ }

"algoritmo" { return PR_ALGORITMO; }
"inicio" { return PR_INICIO; }
"fim_algoritmo" { return PR_FIM_ALGO; }

"LOGICO" { return PR_LOGICO; }
"INTEIRO" { return PR_INTEIRO; }
"REAL" { return PR_REAL; }
"CARACTER" { return PR_CARACTER; }
"REGISTRO" { return PR_REGISTRO; }

"leia"  { return PR_LEIA; }
"escreva" { return PR_ESCREVA; }
"se" { return PR_SE; }
"entao" { return PR_ENTAO; }
"senao" { return PR_SENAO; }
"fim_se" { return PR_FIM_SE; }
"para" { return PR_PARA; }
"ate" { return PR_ATE; }
"passo" { return PR_PASSO; }
"faca" { return PR_FACA; }
"fim_para" { return PR_FIM_PARA; }
"enquanto" { return PR_ENQTO; }
"fim_enquanto" { return PR_FIM_ENQTO; }
"repita" { return PR_REPITA; }
"ABS" { return PR_ABS; }
"TRUNCA" { return PR_TRUNCA; }
"RESTO" { return PR_RESTO; }
"declare" { return PR_DECLARE; }

"entrada" { return PR_ENTRADA; }
"saida" { return PR_SAIDA; }

"funcao" { return PR_FUNCAO; }
"fim_funcao" { return PR_FIM_FUNCAO; }
"procedimento" { return PR_PROCMTO; }
"fim_procedimento" { return PR_FIM_PROCMTO; }

"rad" { return OP_ARIT_RAD; }

{identificador} { insereLista(&lista, yytext); yylval.string = strdup(yytext); return IDENTIFICADOR; }
{num_inteiro} { yylval.integer = atoi(yytext); return NUM_INTEIRO; }
{num_real} { yylval.real = atof(yytext); return NUM_REAL; }
{const_lit} { yylval.string = strdup(yytext); return CONST_LIT; }

"*" { return OP_ARIT_MULT; }
"/" { return OP_ARIT_DIV; }
"+" { return OP_ARIT_ADI; }
"-" { return OP_ARIT_SUB; }
"^" { return OP_ARIT_EXPO; }

"=" { return OP_ATRIB; }

"==" { return OP_REL_IGUAL; }
"!=" { return OP_REL_NAOIGUAL; }
">" { return OP_REL_MAIOR; }
">=" { return OP_REL_MAIORIGUAL; }
"<" { return OP_REL_MENOR; }
"<=" { return OP_REL_MENORIGUAL; }

"!" { return OP_LOG_NAO; }
"&&" { return OP_LOG_AND; }
"||" { return OP_LOG_OR; }


"." { return PONTO; }
"," { return VIRGULA; }
";" { return PONTO_VIRGULA; }
":" { return DOIS_PONTOS; }
"[" { return ABRE_COL; }
"]" { return FECHA_COL; }
"(" { return ABRE_PAR; }
")" { return FECHA_PAR; }
"\"" { return ASPAS; }

. { printf("ERROR\nLine %d: lexical error, unregonized token \"%s\"\n\n", yylineno, yytext);}

%%

/**
Método para desalocar a lista encadeada que representa a tabela de símbolos.
	@param IDENT** obj - O endereço da cabeça da lista encadeada que representa a tabela de símbolos.
	
*/
void freeLista(IDENT** obj) {
	if(*obj != NULL) freeLista(&((*obj)->prox));
	free(*obj);
	*obj = NULL;
}

/**
Método para inserir um novo identificador na tabela de símbolos, utilizando 
chamadas recursivas para chegar ae o fim da lista encadeada.

	@param IDENT** obj - O endereço da cabeça da lista encadeada que representa a tabela de símbolos.
	@param char* lex - O lexema do identificador que se deseja inserir na tabela.

	@return int - Uma flag que indica se foi inserido realmente ou se já estava presente (1-JÁ PRESENTE | 0 - INSERIDO)
	
*/
int insereLista(IDENT** obj, char* lex) {
	IDENT *new;
	if(*obj != NULL) {
		if(!strcmp((*obj)->lexema, lex)) {
			return 1;
		} else {
			return insereLista(&((*obj)->prox), lex);
		}		
	} else {
		new = (IDENT*) malloc(sizeof(IDENT));
		strcpy(new->lexema, lex);
		new->prox = NULL;
		*obj = new;
		return 0;
	}
}


/**
Método usado para exibir os erros sintáticos
	@param char* str - Mensagem de erro gerada pelo bison.
	
*/
void yyerror(const char *str) { 
	printf("ERROR\nLine %d: %s\n", yylineno, str);
}

int yywrap(void) { 
	return 1;
}

int main(int argc, char *argv[]) {
	FILE* file = NULL;

	if ( argc > 1 ) {
		file = fopen(argv[1], "r");
		yyin = file;
	} else {
		printf("ERRO: Execute da seguinte maneira:\n%s [FILE]\n", argv[0]);
		exit(1);
	}

	/* Execução do parser */
	yyparse ();

	/* Exibe a lista de identificadores encontrados. */
	IDENT* iter = lista;
	printf("----------------------------\n| LISTA DE IDENTIFICADORES |\n----------------------------\n");
	while(iter != NULL) {
		printf("%s, ", iter->lexema);
		iter = iter->prox;
	}
	printf("\n");

	freeLista(&lista);
	fclose(file);
	return 0;
}
	 



