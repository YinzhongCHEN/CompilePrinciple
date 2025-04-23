%{
#include<unistd.h>
#include<stdio.h>   
#include "synTree.h"
  #define MAKE_NODE(DEST, LABEL, CNT, ...)      \
    do {                                        \
      DEST = newAst(LABEL, CNT, __VA_ARGS__);   \
      nodeList[nodeNum++] = DEST;               \
    } while(0)
int yylex(void);
%}
%union{
    tnode astNode;
	// 这里声明double是为了防止出现指针错误（segmentation fault）
	double d;
}
/* 词法单元（token）*/
%token <astNode> INT FLOAT ID COMMENT SPACE
%token <astNode> SEMI COMMA ASSIGNOP RELOP
%token <astNode> PLUS MINUS STAR DIV AND OR DOT NOT
%token <astNode> TYPE STRUCT RETURN IF ELSE WHILE
%token <astNode> LP RP LB RB LC RC AERROR

/* 非终结符（语法单元）*/
%type  <astNode> Program ExtDefList ExtDef ExtDecList
%type  <astNode> Specifier StructSpecifier OptTag Tag
%type  <astNode> VarDec FunDec VarList ParamDec
%type  <astNode> CompSt StmtList Stmt
%type  <astNode> DefList Def DecList Dec
%type  <astNode> Exp Args

/*优先级*/
%right ASSIGNOP 
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV 
%right NOT
%left LP RP LB RB DOT

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
/*High-level Definitions*/
Program:ExtDefList {MAKE_NODE($$,"Program",1,$1);}
    ;
ExtDefList:ExtDef ExtDefList {MAKE_NODE($$,"ExtDefList",2,$1,$2);}
	| {$$=newAst("ExtDefList",0,-1);nodeList[nodeNum]=$$;nodeNum++;}
	;
ExtDef:Specifier ExtDecList SEMI    {$$=newAst("ExtDef",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}    
	|Specifier SEMI	{$$=newAst("ExtDef",2,$1,$2);nodeList[nodeNum]=$$;nodeNum++;}
	|Specifier FunDec CompSt	{$$=newAst("ExtDef",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
	;
ExtDecList:VarDec {$$=newAst("ExtDecList",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	|VarDec COMMA ExtDecList {$$=newAst("ExtDecList",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
    |VarDec error ExtDecList {yyerror("text");}/*期望出现逗号但未出现*/
	;
/*Specifier*/
Specifier:TYPE {$$=newAst("Specifier",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	|StructSpecifier {$$=newAst("Specifier",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	;
StructSpecifier:STRUCT OptTag LC DefList RC {$$=newAst("StructSpecifier",5,$1,$2,$3,$4,$5);nodeList[nodeNum]=$$;nodeNum++;}
	|STRUCT Tag {$$=newAst("StructSpecifier",2,$1,$2);nodeList[nodeNum]=$$;nodeNum++;}
	;
OptTag:ID {$$=newAst("OptTag",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	|{$$=newAst("OptTag",0,-1);nodeList[nodeNum]=$$;nodeNum++;}
	;
Tag:ID {$$=newAst("Tag",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	;
/*Declarators*/
VarDec:ID {$$=newAst("VarDec",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	|VarDec LB INT RB {$$=newAst("VarDec",4,$1,$2,$3,$4);nodeList[nodeNum]=$$;nodeNum++;}
	|VarDec LB error RB {yyerror("int");}/*数组变量 应该出现整数 但未出现整数*/
    ;
FunDec:ID LP VarList RP {$$=newAst("FunDec",4,$1,$2,$3,$4);nodeList[nodeNum]=$$;nodeNum++;}
	|ID LP RP {$$=newAst("FunDec",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
    |ID LP error RP {yyerror("VarList");}/*解析函数声明的形参列表遇到错误*/
	;
VarList:ParamDec COMMA VarList {$$=newAst("VarList",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
	|ParamDec {$$=newAst("VarList",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	;
ParamDec:Specifier VarDec {$$=newAst("ParamDec",2,$1,$2);nodeList[nodeNum]=$$;nodeNum++;}
    ;
/*Statement*/
CompSt:LC DefList StmtList RC {$$=newAst("CompSt",4,$1,$2,$3,$4);nodeList[nodeNum]=$$;nodeNum++;}
	;
StmtList:Stmt StmtList{$$=newAst("StmtList",2,$1,$2);nodeList[nodeNum]=$$;nodeNum++;}
	| {$$=newAst("StmtList",0,-1);nodeList[nodeNum]=$$;nodeNum++;}
	;
Stmt:Exp SEMI {$$=newAst("Stmt",2,$1,$2);nodeList[nodeNum]=$$;nodeNum++;}
	|CompSt {$$=newAst("Stmt",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	|RETURN Exp SEMI {$$=newAst("Stmt",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
    |IF LP Exp RP Stmt %prec LOWER_THAN_ELSE {$$=newAst("Stmt",5,$1,$2,$3,$4,$5);nodeList[nodeNum]=$$;nodeNum++;}
    |IF LP Exp RP Stmt ELSE Stmt {$$=newAst("Stmt",7,$1,$2,$3,$4,$5,$6,$7);nodeList[nodeNum]=$$;nodeNum++;}
	|WHILE LP Exp RP Stmt {$$=newAst("Stmt",5,$1,$2,$3,$4,$5);nodeList[nodeNum]=$$;nodeNum++;}
	|Exp error {yyerror("Missing \";\"");}
    ;
/*Local Definitions*/
DefList:Def DefList{$$=newAst("DefList",2,$1,$2);nodeList[nodeNum]=$$;nodeNum++;}
	| {$$=newAst("DefList",0,-1);nodeList[nodeNum]=$$;nodeNum++;}
	;
Def:Specifier DecList SEMI {$$=newAst("Def",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
	//|Specifier error SEMI {yyerror("syntax error");}
	|Specifier DecList error {yyerror("Missing \";\"");}
	;
DecList:Dec {$$=newAst("DecList",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	|Dec COMMA DecList {$$=newAst("DecList",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
	;
Dec:VarDec {$$=newAst("Dec",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
	|VarDec ASSIGNOP Exp {$$=newAst("Dec",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
	;
/*Expressions*/
Exp:Exp ASSIGNOP Exp{$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp AND Exp{$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp OR Exp{$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp RELOP Exp{$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp PLUS Exp{$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp MINUS Exp{$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp STAR Exp{$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp DIV Exp{$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |LP Exp RP{$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |MINUS Exp {$$=newAst("Exp",2,$1,$2);nodeList[nodeNum]=$$;nodeNum++;}
        |NOT Exp {$$=newAst("Exp",2,$1,$2);nodeList[nodeNum]=$$;nodeNum++;}
        |ID LP Args RP {$$=newAst("Exp",4,$1,$2,$3,$4);nodeList[nodeNum]=$$;nodeNum++;}
        |ID LP RP {$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp LB Exp RB {$$=newAst("Exp",4,$1,$2,$3,$4);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp DOT ID {$$=newAst("Exp",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |ID {$$=newAst("Exp",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
        |INT {$$=newAst("Exp",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
        |FLOAT{$$=newAst("Exp",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
		|Exp LB Exp error RB{yyerror("Missing \"]\"");}
        ;
Args:Exp COMMA Args {$$=newAst("Args",3,$1,$2,$3);nodeList[nodeNum]=$$;nodeNum++;}
        |Exp {$$=newAst("Args",1,$1);nodeList[nodeNum]=$$;nodeNum++;}
        ;
%%    