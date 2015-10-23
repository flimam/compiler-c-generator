%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>

using namespace std;

#include "trab.tab.h"

#define TAM_IDENT 100
enum Tipo { NONE, LOGICO, INTEIRO, REAL, CARACTER, REGISTRO };
struct IDENT {
    char lexema[TAM_IDENT];
    Tipo type;
};

FILE* file = NULL;
FILE* output = NULL;
vector<IDENT> tabela;

void insereTabela(const char*);
%}

%option yylineno

delim               [ \t\n]+
identificador       [a-zA-Z][a-zA-Z0-9]{0,31}
num_inteiro         [0-9]+
num_real            [0-9]+,[0-9]+
const_lit           \"(\\.|[^"])*\"
comment             \/\/[^\n]*

%%

{delim}             { /* sem ação para delimitadores. */ }
{comment}           { /* sem ação para comentários simples. */ }

"algoritmo"         { return PR_ALGORITMO; }
"inicio"            { return PR_INICIO; }
"fim_algoritmo"     { return PR_FIM_ALGO; }

"LOGICO"            { return PR_LOGICO; }
"INTEIRO"           { return PR_INTEIRO; }
"REAL"              { return PR_REAL; }
"CARACTER"          { return PR_CARACTER; }
"REGISTRO"          { return PR_REGISTRO; }

"leia"              { return PR_LEIA; }
"escreva"           { return PR_ESCREVA; }
"se"                { return PR_SE; }
"entao"             { return PR_ENTAO; }
"senao"             { return PR_SENAO; }
"fim_se"            { return PR_FIM_SE; }
"para"              { return PR_PARA; }
"ate"               { return PR_ATE; }
"passo"             { return PR_PASSO; }
"faca"              { return PR_FACA; }
"fim_para"          { return PR_FIM_PARA; }
"enquanto"          { return PR_ENQTO; }
"fim_enquanto"      { return PR_FIM_ENQTO; }
"repita"            { return PR_REPITA; }
"ABS"               { yylval.string = strdup(yytext); return PR_ABS; }
"TRUNCA"            { yylval.string = strdup(yytext); return PR_TRUNCA; }
"RESTO"             { yylval.string = strdup(yytext); return PR_RESTO; }
"declare"           { return PR_DECLARE; }

"entrada"           { return PR_ENTRADA; }
"saida"             { return PR_SAIDA; }

"funcao"            { return PR_FUNCAO; }
"fim_funcao"        { return PR_FIM_FUNCAO; }
"procedimento"      { return PR_PROCMTO; }
"fim_procedimento"  { return PR_FIM_PROCMTO; }

"rad"               { return OP_ARIT_RAD; }

{identificador}     { insereTabela(strdup(yytext)); yylval.string = strdup(yytext); return IDENTIFICADOR; }
{num_inteiro}       { yylval.string = strdup(yytext); return NUM_INTEIRO; }
{num_real}          { yylval.string = strdup(yytext); return NUM_REAL; }
{const_lit}         { yylval.string = strdup(yytext); return CONST_LIT; }

"*"                 { yylval.string = strdup(yytext); return OP_ARIT_MULT; }
"/"                 { yylval.string = strdup(yytext); return OP_ARIT_DIV; }
"+"                 { yylval.string = strdup(yytext); return OP_ARIT_ADI; }
"-"                 { yylval.string = strdup(yytext); return OP_ARIT_SUB; }
"^"                 { yylval.string = strdup(yytext); return OP_ARIT_EXPO; }

"="                 { yylval.string = strdup(yytext); return OP_ATRIB; }

"=="                { yylval.string = strdup(yytext); return OP_REL_IGUAL; }
"!="                { yylval.string = strdup(yytext); return OP_REL_NAOIGUAL; }
">"                 { yylval.string = strdup(yytext); return OP_REL_MAIOR; }
">="                { yylval.string = strdup(yytext); return OP_REL_MAIORIGUAL; }
"<"                 { yylval.string = strdup(yytext); return OP_REL_MENOR; }
"<="                { yylval.string = strdup(yytext); return OP_REL_MENORIGUAL; }

"!"                 { yylval.string = strdup(yytext); return OP_LOG_NAO; }
"&&"                { yylval.string = strdup(yytext); return OP_LOG_AND; }
"||"                { yylval.string = strdup(yytext); return OP_LOG_OR; }


"."                 { return PONTO; }
","                 { return VIRGULA; }
";"                 { return PONTO_VIRGULA; }
":"                 { return DOIS_PONTOS; }
"["                 { return ABRE_COL; }
"]"                 { return FECHA_COL; }
"("                 { return ABRE_PAR; }
")"                 { return FECHA_PAR; }
"\""                { return ASPAS; }
.                   { printf("ERROR\nLine %d: lexical error, unregonized token \"%s\"\n\n", yylineno, yytext);}

%%

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

void insereTabela(const char* buffer) {
    IDENT obj;
    for(int i = 0; i < tabela.size(); i++) {
        if(!strcmp(tabela[i].lexema, buffer)) return;
    }
    obj.type = NONE;
    strcpy(obj.lexema, buffer);
    tabela.push_back(obj);
}

int main(int argc, char *argv[]) {
    /* Abertura do arquivo de entrada. */
    if ( argc > 1 ) {
        file = fopen(argv[1], "r");
        yyin = file;
    } else {
        printf("ERRO: Execute da seguinte maneira:\n%s [FILE]\n", argv[0]);
        exit(1);
    }
    
    /* Abertura do arquivo de saída, com nome de arquivo escolhido ou padrão. */
    if (argc == 3) {
        output = fopen(argv[2], "w");
    } else {
        output = fopen("output.c", "w");
    }

    /* Execução do parser */
    yyparse ();

    /* Exibe a lista de identificadores encontrados. */
    printf("\n----------------------------\n| LISTA DE IDENTIFICADORES |\n----------------------------\n");
    
    for(int i = 0; i < tabela.size(); i++) {
        printf("%s, ", tabela[i].lexema);
    }
    printf("\n\n");

    fclose(file);
    fclose(output);
    return 0;
}
     



