%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>

using namespace std;

#define TAM_IDENT 100
enum Tipo { NONE, LOGICO, INTEIRO, REAL, CARACTER, REGISTRO, ARRAY_LOGICO, ARRAY_INTEIRO, ARRAY_REAL, ARRAY_CARACTER, ARRAY_REGISTRO, FUNC };
struct IDENT {
	char lexema[TAM_IDENT];
	Tipo type;
	bool used;
};

extern int yylex ();
extern void yyerror (const char *);
extern void yywarning (const char *);
extern FILE* output;
extern vector<IDENT> tabela;
vector<char*> pilha, cp;
bool func;

char PR_ALGORITMO_C[] = "#include <stdio.h>\n#include <stdlib.h>\n\n";
char MACROS_C[] = "#define RESTO(x,y) (x%y)\n#define ABS(x) (x >= 0 ? x:-x)\n#define TRUNCA(x) ((int) (x/1))\n\n";
char PR_INICIO_C[] = "int main (int argc, char* argv[]) {\n\n";
char PR_FIM_ALGO_C[] = "return 0;\n}\n";

char PR_REGISTRO_C[] = "typedef struct ";
Tipo tipos;

void put(const char* buffer) {
	fprintf(output, "%s", buffer);
}

char getType(char* var) {
	char resp = '?';
	char *bu2, *bu = strdup(var);
	bu2 = bu;
	// quebra da variável de struct
	for(int i = strlen(bu)-1; i >= 0; i--) {
		if(bu[i] == '.') {
			bu = &var[++i];
			break;
		}
	}

	// quebra da variável do tipo "vetor"
	for(int i = 0; i < strlen(bu); i++) {
		if(bu[i] == '[') {
			bu[i] = '\0';
			break;
		}
	}

	for(int i = 0; i < tabela.size(); i++) {
		if(!strcmp(bu, tabela[i].lexema)) {
			switch(tabela[i].type) {
				case INTEIRO:
				case LOGICO:
				case ARRAY_INTEIRO:
				case ARRAY_LOGICO:
				resp = 'd';
				break;

				case REAL:
				case ARRAY_REAL:
				resp = 'f';
				break;

				case CARACTER:
				resp = 'c';
				break;

				case ARRAY_CARACTER:
				resp = 's';
				break;

				case FUNC:
				resp = 'p';
				break;
			}
			break;
		}
	}
	free(bu2);
	return resp;
}

void makeprintf() {
	for(int i = 0; i < pilha.size(); i++) {
		if (pilha[i][0] == '"') {
			fprintf(output, "printf(%s);\n", pilha[i]);
		} else {
			fprintf(output, "printf(\"%%%c\", %s);\n", getType(pilha[i]), pilha[i]);
		}
	}
	pilha.clear();
}

void makescanf() {
	char type, addr;
	for(int i = 0; i < pilha.size(); i++) {
		type = getType(pilha[i]);
		addr = (type != 's') ? '&' : ' ';
		fprintf(output, "scanf(\"%%%c\", %c%s);\n", type, addr, pilha[i]);
	}
	pilha.clear();
}

bool set_type(char *lexema, bool is_vector) {
	for(int i = 0; i < tabela.size(); i++) {
		if(!strcmp(tabela[i].lexema, lexema)) {
			if(tabela[i].type != NONE) {
				char* b;
				asprintf(&b, "Identifier \"%s\" is already declared", lexema);
				yyerror(b);
				free(b);
				return true;
			}
			if(is_vector) {
				switch(tipos) {
					case LOGICO:
						tipos = ARRAY_LOGICO;
					break;

					case INTEIRO:
						tipos = ARRAY_INTEIRO;
					break;

					case REAL:
						tipos = ARRAY_REAL;
					break;

					case CARACTER:
						tipos = ARRAY_CARACTER;
					break;

					case REGISTRO:
						tipos = ARRAY_REGISTRO;
					break;
				}
			}
			tabela[i].type = tipos;
			tabela[i].used = false;
			return true;
		}
	}
	return false;
}

char* makedeclare(char* tipo) {
	char bu[100] = "";

	if(tipos == REGISTRO) {
		int num = rand() % 1000;
		sprintf(bu, "typedef struct st_%d {\n%s} st_%d;\nst_%d ", num, tipo, num, num);
	} else {
		sprintf(bu, "%s ", tipo);
	}

	for (int i = 0; i < pilha.size(); i++) {
		char *lexema;
		bool is_vector = false;
		if(pilha[i][0] == '[') {
			lexema = pilha[i + 1];
			pilha.erase(pilha.begin() + i + 1);
			sprintf(bu, "%s%s%s", bu, lexema, pilha[i]);
			is_vector = true;
		} else {
			sprintf(bu, "%s%s", bu, pilha[i]);
			lexema = pilha[i];
		}
		if(!set_type(lexema, is_vector)) {
			printf("Lexema not found: %s\n\n", lexema);
		}
		if(i < pilha.size() - 1) {
			sprintf(bu, "%s, ", bu);
		}
	}
	if(pilha.size() > 0) {
		sprintf(bu, "%s;\n", bu);
	}
	return strdup(bu);
}

char* makelist() {
	char bu[TAM_IDENT] = "";
	for (int i = 0; i < pilha.size(); i++) {
		strcat(bu, pilha[i]);
		if(i < pilha.size()-1) {
			strcat(bu, ",");
		}
	}
	pilha.clear();
	return strdup(bu);
}

void makevector(char* num_total) {
	char *num, *temp;
	int numero = atoi(num_total);
	asprintf(&num, "[%d]", numero);
	if(pilha.size()) {
		if(pilha.back()[0] == '[') {
			temp = pilha.back();
			pilha.pop_back();
			strcat(num, temp);
		}
	}
	pilha.push_back(num);
}

void makefunction(char* id) {

	char bu[TAM_IDENT] = "";
	char *tipo, *retorno;

	tipos = FUNC;
	set_type(id, false);

	tipos = (Tipo) atoi(pilha.back());
	pilha.pop_back();

	tipo = pilha.back();
	pilha.pop_back();
	retorno = pilha.back();
	pilha.pop_back();

	set_type(retorno, false);

	for (int i = 0; i < pilha.size(); i+=3) {
		sprintf(bu, "%s%s %s", bu, pilha[i+1], pilha[i]);

		tipos = (Tipo) atoi(pilha[i+2]);
		set_type(pilha[i], false);

		if(i < pilha.size()-3) {
			strcat(bu, ", ");
		}
	}

	fprintf(output,"%s %s(%s) {\n%s %s;\n", tipo, id, bu, tipo, retorno);

	free(id);
	free(tipo);
	pilha.clear();
}

void makeprocedure(char* id) {
	char bu[TAM_IDENT] = "";

	tipos = FUNC;
	set_type(id, false);

	for (int i = 0; i < pilha.size(); i+=3) {
		sprintf(bu, "%s%s %s", bu, pilha[i+1], pilha[i]);

		tipos = (Tipo) atoi(pilha[i+2]);
		set_type(pilha[i], false);

		if(i < pilha.size()-3) {
			strcat(bu, ", ");
		}
	}
	fprintf(output,"void %s(%s) {\n", id, bu);
	free(id);
	pilha.clear();
}

/*
Verifica se a variável foi declarada na tabela de símbolos
*/
void existsvar(char* var) {
	if (!func){
		char* b;
		for(int i = 0; i < tabela.size(); i++) {
			if(!strcmp(tabela[i].lexema, var) && tabela[i].type != NONE) {
				tabela[i].used = true;
				return;
			}
		}
		asprintf(&b, "Identifier \"%s\" used but not declared", var);
		yywarning(b);
		free(b);
	}
}

void check_uses() {
	char* b;
	for(int i = 0; i < tabela.size(); i++) {
		if(!tabela[i].used && tabela[i].type != NONE) {
			asprintf(&b, "Identifier \"%s\" declared but not used", tabela[i].lexema);
			yywarning(b);
			free(b);
		}
	}
}

%}

%union {
	int integer;
	char *string;
	double real;
}

// Ativa as mensagens de erro sintático
%error-verbose

// Declaração dos tokens utilizados no compilador

%token <string> IDENTIFICADOR CONST_LIT NUM_INTEIRO NUM_REAL

%token <string> OP_ATRIB OP_ARIT_MULT OP_ARIT_DIV OP_ARIT_ADI OP_ARIT_SUB OP_ARIT_EXPO OP_ARIT_RAD

%token <string> OP_REL_IGUAL OP_REL_NAOIGUAL OP_REL_MAIOR OP_REL_MAIORIGUAL OP_REL_MENOR OP_REL_MENORIGUAL

%token <string> OP_LOG_NAO OP_LOG_AND OP_LOG_OR

%token <string> PONTO VIRGULA PONTO_VIRGULA DOIS_PONTOS ABRE_COL FECHA_COL ABRE_PAR FECHA_PAR ASPAS


%token <string> PR_ALGORITMO PR_INICIO PR_FIM_ALGO
%token <string> PR_LOGICO PR_INTEIRO PR_REAL PR_CARACTER PR_REGISTRO
%token <string> PR_LEIA PR_ESCREVA
%token <string> PR_SE PR_ENTAO PR_SENAO PR_FIM_SE
%token <string> PR_PARA PR_ATE PR_PASSO PR_FACA PR_FIM_PARA PR_ENQTO PR_FIM_ENQTO PR_REPITA PR_ABS PR_TRUNCA PR_RESTO PR_DECLARE

%token <string> PR_FUNCAO PR_ENTRADA PR_SAIDA PR_FIM_FUNCAO PR_PROCMTO PR_FIM_PROCMTO

%type <string> decl reg algo tipo l_var l_vrs exp_a term_a fat_a adisub muldiv func exp exp_l op_rel rel fat_r op_log ind cmds cond l_param l_params procs param

%type <string> var
// Não-terminal inicial
%start algo

%%

// Definição das produções da gramática

algo:		PR_ALGORITMO { put(PR_ALGORITMO_C); put(MACROS_C); } IDENTIFICADOR procs PR_INICIO { put(PR_INICIO_C); } decl { fprintf(output, "%s\n", $7); } cmds PR_FIM_ALGO { put(PR_FIM_ALGO_C); check_uses(); };

decl:		PR_DECLARE { pilha.clear(); } l_ids DOIS_PONTOS tipo PONTO_VIRGULA { $5 = makedeclare($5); } decl { asprintf(&$$, "%s%s", $5, $8); free($5); free($8); }
		|	PR_DECLARE error PONTO_VIRGULA decl { $$ = $4; yyerror("Declaration error, ignoring variable"); }
		|	%empty { $$ = strdup(""); };

l_ids:		IDENTIFICADOR comp { pilha.push_back($1); } lids {};

lids:		VIRGULA l_ids {}
		|	%empty {};

comp:		ABRE_COL dim FECHA_COL {}
		|	ABRE_COL error FECHA_COL { yyerror("Bad dimension"); }
		|	%empty {};

dim:		NUM_INTEIRO PONTO PONTO NUM_INTEIRO dims { makevector($4); };

dims:		VIRGULA dim {}
		|	%empty {};

tipo:		PR_LOGICO { $$ = strdup("int"); tipos = LOGICO; }
		|	PR_CARACTER { $$ = strdup("char"); tipos = CARACTER; }
		|	PR_INTEIRO { $$ = strdup("int"); tipos = INTEIRO; }
		|	PR_REAL { $$ = strdup("float"); tipos = REAL; }
		|	IDENTIFICADOR { existsvar($1); $$ = $1; tipos = NONE; }
		|	reg { $$ = $1; };

reg:		PR_REGISTRO ABRE_PAR { cp = pilha; } decl FECHA_PAR { pilha = cp; tipos = REGISTRO; $$ = $4; };

cmds:		PR_LEIA { pilha.clear(); } l_var { makescanf(); } cmds {}
		|	PR_LEIA error cmds { yyerror("Error on scanf"); }

		|	PR_ESCREVA { pilha.clear(); } l_var { makeprintf(); } cmds {}
		|	PR_ESCREVA error cmds { yyerror("Error on printf"); }

		|	IDENTIFICADOR { existsvar($1); } OP_ATRIB exp { fprintf(output, "%s = %s;\n", $1, $4); free($4); } cmds {}
		|	IDENTIFICADOR error cmds { yyerror("Error on attribution"); }

		|	PR_SE cond PR_ENTAO { fprintf(output, "if (%s) {\n", $2); free($2); } cmds sen PR_FIM_SE { put("}\n"); } cmds {}

		|	PR_PARA IDENTIFICADOR OP_ATRIB exp_a PR_ATE exp_a PR_PASSO exp_a PR_FACA { fprintf(output, "for (%s = %s; %s <= %s; %s+=%s) {\n", $2, $4, $2, $6, $2, $8); free($4); free($6); free($8); } cmds PR_FIM_PARA { put("}\n"); } cmds {}
		
		|	PR_ENQTO cond PR_FACA { fprintf(output, "while (%s) {\n", $2); free($2); } cmds PR_FIM_ENQTO { put("}\n"); } cmds {}

		|	PR_REPITA { put("do {\n"); } cmds PR_ATE cond { fprintf(output, "} while (!(%s));\n", $5); free($5); } cmds {}

		| 	IDENTIFICADOR { existsvar($1); } ABRE_PAR { pilha.clear(); } l_var FECHA_PAR { fprintf(output, "%s(%s)", $1, makelist()); free($1); } cmds {}
		
		|	%empty {};

l_var:		var { pilha.push_back($1); } l_vrs
		|	NUM_INTEIRO { pilha.push_back($1); } l_vrs
		|	CONST_LIT { pilha.push_back($1); } l_vrs;

l_vrs:		VIRGULA l_var
		|	%empty {};

var:		IDENTIFICADOR { existsvar($1); } ind { asprintf(&$$, "%s%s", $1, $3); free($1); free($3); }

ind:		ABRE_COL exp_a FECHA_COL ind { asprintf(&$$, "[%s]%s", $2, $4); free($2); free($4); }
		|	PONTO IDENTIFICADOR { existsvar($2); } ind { asprintf(&$$, ".%s%s", $2, $4); free($2); free($4); }
		|	%empty { $$ = strdup(""); };

sen:		PR_SENAO { put("} else {\n"); } cmds {}
		|	%empty;

param:		var DOIS_PONTOS tipo { pilha.push_back($1); pilha.push_back($3); char *ub; asprintf(&ub, "%d", tipos); pilha.push_back(ub); $$ = $1; };

l_param:	param l_params;

l_params:	VIRGULA l_param
		|	%empty {};

procs:		PR_FUNCAO IDENTIFICADOR PR_ENTRADA { pilha.clear(); func = true; } l_param PR_SAIDA param { makefunction($2); func = false; } decl cmds PR_FIM_FUNCAO { fprintf(output,"return %s;\n}\n\n",$7); free($7); } procs {}

		|	PR_PROCMTO IDENTIFICADOR PR_ENTRADA { pilha.clear(); func = true; } l_param { makeprocedure($2); func = false; } decl cmds PR_FIM_PROCMTO { put("}\n\n"); } procs {}

		|	PR_FUNCAO error PR_FIM_FUNCAO procs { yyerror("On FUNCAO definition. ignoring.."); }
		|	PR_PROCMTO error PR_FIM_PROCMTO procs { yyerror("On PROCMTO definition. ignoring.."); }
		|	%empty {};

exp:		exp_l { $$ = $1; }
		|	exp_a { $$ = $1; };

exp_a:		term_a muldiv exp_a { asprintf(&$$, "%s%s%s", $1, $2, $3);  free($1); free($2); free($3); }
		|	term_a { $$ = $1; };

term_a:		fat_a adisub term_a { asprintf(&$$, "%s%s%s", $1, $2, $3);  free($1); free($2); free($3);}
		|	fat_a { $$ = $1; };

fat_a:		exp_a OP_ARIT_EXPO exp_a { asprintf(&$$, "%s%s%s", $1, $2, $3); free($1); free($2); free($3); }
		|	exp_a OP_ARIT_RAD exp_a { asprintf(&$$, "%s%s%s", $1, $2, $3); free($1); free($2); free($3); }
		|	ABRE_PAR exp_a FECHA_PAR { asprintf(&$$, "(%s)", $2); free($2); }
		|	func ABRE_PAR { pilha.clear(); } l_var FECHA_PAR { asprintf(&$$, "%s(%s)", $1, makelist()); free($1); }
		|	var { $$ = $1; }
		|	NUM_INTEIRO { $$ = $1; }
		|	NUM_REAL { $$ = $1; };

muldiv:		OP_ARIT_MULT { $$ = $1; }
		|	OP_ARIT_DIV { $$ = $1; };

adisub:		OP_ARIT_ADI { $$ = $1; }
		|	OP_ARIT_SUB { $$ = $1; };

func:		PR_ABS { $$ = $1; }
		|	PR_TRUNCA { $$ = $1; }
		|	PR_RESTO { $$ = $1; }
		|	IDENTIFICADOR { existsvar($1); $$ = $1; }

exp_l:		rel op_log exp_l { asprintf(&$$, "%s %s %s", $1, $2, $3); free($1); free($2); free($3); }
		|	OP_LOG_NAO ABRE_PAR rel FECHA_PAR { asprintf(&$$, "%s(%s)", $1, $3); free($1); free($3); }
		| 	rel { $$ = $1; };

rel:		fat_r op_rel fat_r { asprintf(&$$, "%s %s %s", $1, $2, $3); free($1); free($2); free($3); };

fat_r:		fat_a { $$ = $1; }
		|	CONST_LIT { $$ = $1; };

op_log:		OP_LOG_AND { $$ = $1; }
		|	OP_LOG_OR { $$ = $1; };

op_rel:		OP_REL_IGUAL { $$ = $1; }
		|	OP_REL_NAOIGUAL { $$ = $1; }
		|	OP_REL_MAIOR { $$ = $1; }
		|	OP_REL_MAIORIGUAL { $$ = $1; }
		|	OP_REL_MENOR { $$ = $1; }
		|	OP_REL_MENORIGUAL { $$ = $1; };

cond:		ABRE_PAR exp_l FECHA_PAR { $$ = $2; }
		|	ABRE_PAR error FECHA_PAR { yyerror("Bad condition"); };
