%{
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
int yyerror(const char *s);
int yylex(void);
int errorc = 0;
extern FILE *yyin;

typedef struct {
	char *nome;
	int token;
} simbolo;

enum typeno {NFUNC, MAINFUNC, NIF, NELSE, NFOR, NSTRUCT, NRETURN, NIDENT, NOPERB, NOPERBL, 
	NCONST, FORATRIB, NARGS, NTYPE, NFIELDS, NSTMTS, NSTMTX, NINCLUDE, NPROG, NATTRIB};

struct syntaticno {
	int id;
	enum typeno type;
	char *label;
	simbolo *sim;
	int constvalue;
	int qtdfilhos;
	struct syntaticno *filhos[1]; // ultimo campo
};
typedef struct syntaticno syntaticno;

int simbolo_qtd = 0;
simbolo tsimbolos[100];
simbolo *simbolo_novo(char *nome, int token);
simbolo *simbolo_existe(char *nome);
syntaticno *novo_syntaticno(enum typeno type, char *label, int filhos);
void debug(syntaticno *root);
%}

%define parse.error verbose

/* atributos dos tokens */
%union {
	char *nome;
	int valor;
	struct syntaticno *no;
}

%token NUMBER IDENT TINT TFLOAT RETURN
%token STRUCT IF ELSE FOR
%token OR AND LE_OP GE_OP INC_OP PAREN EQUALS DIF

%type <nome> IDENT
%type <valor> NUMBER
%type <no> prog arit expr term factor stmts stmt type args arg
%type <no> fields field logica terml factorl exprl stmtx

%start prog

%%

prog : stmts		{ if (errorc > 0)
						printf("%d erro(s) encontrados(s)\n", errorc);
					  else {
						printf("programa reconhecido\n");
						syntaticno *root = novo_syntaticno(NPROG, "prog", 1);
						root->filhos[0] = $1;
						debug(root);
					  }
					}
	 ;

stmts : stmts stmt {
			$$ = novo_syntaticno(NSTMTS, "stmts", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $2;	
	    }

      | stmt { $$ = $1; }
      ;

stmt : type IDENT '=' arit ';' {
       		char aux[20];
			sprintf(aux, "%s =", $2);
			$$ = novo_syntaticno(NATTRIB, strdup(aux), 1);
			$$->filhos[0] = $4;
	   }

	 | IDENT '=' arit ';' {
       		char aux[20];
			sprintf(aux, "%s =", $1);
			$$ = novo_syntaticno(NATTRIB, strdup(aux), 1);
			$$->filhos[0] = $3;
	   }

	 | type IDENT ';' {
			$$ = novo_syntaticno(NIDENT, $2, 0);
	   }
		
	 | type IDENT '(' args ')' '{' stmts '}' {
			$$ = novo_syntaticno(NFUNC, $2, 2);
			$$->filhos[0] = $4;
			$$->filhos[1] = $7;	
	   }
	   // int main() { stmts }
	 | type IDENT PAREN '{' stmts '}' {
			$$ = novo_syntaticno(MAINFUNC, $2, 1);
			$$->filhos[0] = $5;	
	   }
	   // int main() {  }
	 | type IDENT PAREN '{''}' {
			$$ = novo_syntaticno(MAINFUNC, $2, 0);
	   }
	 | IDENT '=' IDENT '(' IDENT ')' ';' {
			$$ = novo_syntaticno(FORATRIB, $1, 1);
			$$->filhos[0] = novo_syntaticno(NIDENT, $3, 0);
	   }
	 | IDENT '=' IDENT PAREN ';' {
			$$ = novo_syntaticno(FORATRIB, $1, 1);
			$$->filhos[0] = novo_syntaticno(NIDENT, $3, 0);
	   }

	/* #include <stdio.h> */
	 | '#' IDENT '<' IDENT '.' IDENT '>' {
			$$ = novo_syntaticno(NINCLUDE, "include", 0);
	   }

	 | RETURN arit ';' {
			$$ = novo_syntaticno(NRETURN, "return", 1);
			$$->filhos[0] = $2;
	   }

	 /* struct { int a; } exemplo; */
	 | STRUCT '{' fields '}' IDENT ';' {
			$$ = novo_syntaticno(NSTRUCT, "struct", 2);
			$$->filhos[0] = novo_syntaticno(NIDENT, $5, 0);
			$$->filhos[1] = $3;
	   }

	 | IF '(' logica ')' '{' stmts '}' {
			$$ = novo_syntaticno(NIF, "ifblock", 2);
			$$->filhos[0] = $3;
			$$->filhos[1] = $6;
	   }
	 | ELSE '{' stmts '}' {
			$$ = novo_syntaticno(NELSE, "elseblock", 1);
			$$->filhos[0] = $3;
	   }
	 | FOR '(' stmtx ';' logica ';' stmtx ')' '{' stmts '}' {
			$$ = novo_syntaticno(NFOR, "forblock", 4);
			$$->filhos[0] = $3;
			$$->filhos[1] = $5;
			$$->filhos[2] = $7;
			$$->filhos[3] = $10;
	   } 
     ;

stmtx : type IDENT '=' factor {
			char aux[20];
			sprintf(aux, "%s =", $2);
			$$ = novo_syntaticno(NSTMTX, strdup(aux), 1);
			$$->filhos[0] = $4;
		}
		| term INC_OP {
			$$ = novo_syntaticno(NIDENT, "term", 0);
		}
		;

fields : field fields {
			$$ = novo_syntaticno(NFIELDS, "fields", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $2;		
		 }

	   | field	{ $$ = $1; }
	   ;

field : type IDENT ';' {
			$$ = novo_syntaticno(NIDENT, $2, 0);
		 }
	   ;

type : TINT		{ $$ = novo_syntaticno(NTYPE, "int", 0); }
	 | TFLOAT	{ $$ = novo_syntaticno(NTYPE, "float", 0); }
	 ;

args : arg ',' args {
			$$ = novo_syntaticno(NARGS, "args", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;	
	   }

	 | arg { $$ = $1; }
	 | %empty { $$ = novo_syntaticno(NARGS, "noargs", 0); }
	 ;

arg : type IDENT { 
		$$ = novo_syntaticno(NARGS, "arg", 2);
		$$->filhos[0] = $1;
		$$->filhos[1] = novo_syntaticno(NIDENT, $2, 0);
	  }
	;

logica : exprl
	   | exprl error
	   ;

exprl : exprl OR terml  {
			$$ = novo_syntaticno(NOPERBL, "or", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	   }
	 | exprl '<' term {
			$$ = novo_syntaticno(NOPERBL, "<", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	 } 
	 | exprl DIF term {
			$$ = novo_syntaticno(NOPERBL, "!=", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	 }
	 | exprl EQUALS term {
			$$ = novo_syntaticno(NOPERBL, "==", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	 }
	 | exprl AND term {
			$$ = novo_syntaticno(NOPERBL, "and", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	 }
	 | terml	{ $$ = $1; }
	 ;

terml : terml AND factorl {
			$$ = novo_syntaticno(NOPERBL, "and", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	   }

	   | factorl { $$ = $1; }
	   ;

factorl : '(' exprl ')' {
			/*$$ = novo_syntaticno("()", 1);
			$$->filhos[0] = $2;*/
			$$ = $2;
		 }
		| arit { $$ = $1; }
		;

arit : expr	{ $$ = $1; }
	 | expr error
	 ;

expr : expr '+' term  {
			printf("+\n");
			$$ = novo_syntaticno(NOPERB, "+", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	   }

	 | expr '-' term {
			$$ = novo_syntaticno(NOPERB, "-", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	   }

	 | term	{ $$ = $1; }
	 ;

term : term '*' factor {
			printf("*\n");
			$$ = novo_syntaticno(NOPERB, "*", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	   }

	 | term '/' factor {
		 	printf("/\n");
			$$ = novo_syntaticno(NOPERB, "/", 2);
			$$->filhos[0] = $1;
			$$->filhos[1] = $3;
	   }

	 | factor			{ $$ = $1; }
	 ;

factor : '(' expr ')' {
			/*$$ = novo_syntaticno("()", 1);
			$$->filhos[0] = $2;*/
			$$ = $2;
		 }

	   | NUMBER {
			$$ = novo_syntaticno(NCONST, "const", 0);
			$$->constvalue = $1;
		 }
	   | IDENT {
			simbolo *s = simbolo_existe($1);
			if (!s)
				s = simbolo_novo($1, IDENT);
			$$ = novo_syntaticno(NIDENT, "IDENT", 0);
			$$->sim = s;
		 }
	   ;

%%

int yywrap() {
	return 1;
}

int yyerror(const char *s) {
	errorc++;
	printf("erro %d: %s\n", errorc, s);
	return 1;
}

simbolo *simbolo_novo(char *nome, int token) {
	tsimbolos[simbolo_qtd].nome = nome;
	tsimbolos[simbolo_qtd].token = token;
	simbolo *result = &tsimbolos[simbolo_qtd];
	simbolo_qtd++;
	return result;
}

simbolo *simbolo_existe(char *nome) {
	// busca linear, nao eficiente
	for(int i = 0; i < simbolo_qtd; i++) {
		if (strcmp(tsimbolos[i].nome, nome) == 0)
			return &tsimbolos[i];
	}
	return NULL;
}

syntaticno *novo_syntaticno(enum typeno type, char *label, int filhos) {
	static int nid = 0;
	int s = sizeof(syntaticno);
	if (filhos > 1)
		s += sizeof(syntaticno*) * (filhos-1);
	syntaticno *n = (syntaticno*)calloc(1, s);
	n->id = nid++;
	n->type = type;
	n->label = label;
	n->qtdfilhos = filhos;
	return n;
}

void translate_arit_logica(syntaticno *n) {
	if (n->qtdfilhos >= 1)
		translate_arit_logica(n->filhos[0]);

	if (n->sim)
		printf(" %s", n->sim->nome);
	else if (strcmp(n->label, "const") == 0)
		printf(" %d", n->constvalue);
	else
		printf(" %s", n->label);

	if (n->qtdfilhos == 2)
		translate_arit_logica(n->filhos[1]);
}

void translate_arit_logica_for_dir(syntaticno *n) {
	if(n->qtdfilhos == 3) {
	if (n->sim)
		printf(" %s", n->sim->nome);
	else if (strcmp(n->label, "const") == 0)
		printf(" %d", n->constvalue);
	else
		printf(" %s", n->label);
	}
	if (n->qtdfilhos == 2)
		translate_arit_logica(n->filhos[1]);
}

void translate_arit_logica_for_esq(syntaticno *n) {
	if (n->qtdfilhos >= 1)
		translate_arit_logica(n->filhos[0]);

	if (n->sim)
		printf(" %s", n->sim->nome);
	else if (strcmp(n->label, "const") == 0)
		printf(" %d", n->constvalue);
	
}


void printlevel(int level) {
	for(int i = 0; i < level; i++)
		printf("\t");
}

void translate(int level, syntaticno *n) {

	switch (n->type) {
		case NATTRIB:
			printlevel(level);
			printf("%s", n->label);
			translate_arit_logica(n->filhos[0]);
			printf("\n");
			break;

		case NIF:
			printlevel(level);
			printf("if ");
			translate_arit_logica(n->filhos[0]);
			printf(":\n");
			translate(level+1, n->filhos[1]);
			break;
		
		case NELSE:
			printlevel(level);
			printf("else:\n");
			translate(level+1, n->filhos[0]);
			break;

		case NFUNC:
			printlevel(level);
			printf("def %s():\n", n->label);
			translate(level+1, n->filhos[1]);
			break;
		
		case MAINFUNC:
			printlevel(level);
			printf("def %s():\n", n->label);
			translate(level+1, n->filhos[0]); // PROBLEMA AQUI
			break;

		case NRETURN:
			printlevel(level);
			printf("return ");
			translate_arit_logica(n->filhos[0]);
			printf("\n");
			break;

		case NFOR:
			printlevel(level);
			printf("for");
			translate_arit_logica_for_esq(n->filhos[1]);
			printf(" in range (");
			translate_arit_logica_for_dir(n->filhos[1]);
			printf(" ):\n");
			translate(level+1, n->filhos[3]);
			break;

		case FORATRIB:
			printlevel(level);
			printf("%s =", n->label);
			translate_arit_logica(n->filhos[0]);
			printf("()\n");
			break;
		
		default:
			//printf("#%s\n", n->label);
			for(int i=0; i < n->qtdfilhos; i++)
				translate(level, n->filhos[i]);
	}
}

void print_tree(syntaticno *n) {

	if (n->sim)
		printf("\tn%d [label=\"%s\"];\n", n->id, n->sim->nome);
	else if (strcmp(n->label, "const") == 0)
		printf("\tn%d [label=\"%d\"];\n", n->id, n->constvalue);
	else
		printf("\tn%d [label=\"%s\"];\n", n->id, n->label);

	for(int i=0; i < n->qtdfilhos; i++)
		print_tree(n->filhos[i]);
	for(int i=0; i < n->qtdfilhos; i++)
		printf("\tn%d -- n%d\n", n->id, n->filhos[i]->id);
}

void debug(syntaticno *no) {
	printf("Simbolos: \n");
	for(int i = 0; i < simbolo_qtd; i++) {
		printf("\t%s\n", tsimbolos[i].nome);
	}
	/* graph prog { ... } */
	printf("AST: \n");
	printf("graph prog {\n");
	print_tree(no);
	printf("}\n");

	translate(0, no);
}

int main(int argc, char *argv[]) {
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
	}
	yyparse();
	if (yyin)
		fclose(yyin);
}
