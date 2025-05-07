%{
#include<unistd.h>
#include<stdio.h>   
#include "synTree.h"
  #define CREATE_NODE(DEST, LABEL, CNT, ...)      \
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
// /*%expect  6
%%
/*High-level Definitions*/
Program:ExtDefList                  {CREATE_NODE($$,"Program",1,$1);}
    ;
ExtDefList:ExtDef ExtDefList        {CREATE_NODE($$,"ExtDefList",2,$1,$2);}
	|                               {CREATE_NODE($$,"ExtDefList",0,-1);}
	;
ExtDef:Specifier ExtDecList SEMI    {CREATE_NODE($$,"ExtDef",3,$1,$2,$3);}    
	|Specifier SEMI	                {CREATE_NODE($$,"ExtDef",2,$1,$2);}
	|Specifier FunDec CompSt	    {CREATE_NODE($$,"ExtDef",3,$1,$2,$3);} 
	;
ExtDecList:VarDec                   {CREATE_NODE($$,"ExtDecList",1,$1);}
	|VarDec COMMA ExtDecList        {CREATE_NODE($$,"ExtDecList",3,$1,$2,$3);}
    |VarDec error ExtDecList        {yyerror("Missing \",\"");}/*期望出现逗号但未出现*/
	;
/*Specifier*/
Specifier:StructSpecifier           {CREATE_NODE($$,"Specifier",1,$1);}
	|TYPE                           {CREATE_NODE($$,"Specifier",1,$1);}
	//|error {yyerror("Error: Unsupported type");}
	;
StructSpecifier:STRUCT OptTag LC DefList RC {CREATE_NODE($$,"StructSpecifier",5,$1,$2,$3,$4,$5);}
	|STRUCT Tag                             {CREATE_NODE($$,"StructSpecifier",2,$1,$2);}
	|STRUCT OptTag LC DefList error         {yyerror("Missing '}'");}
	;
OptTag:ID                                   {CREATE_NODE($$,"OptTag",1,$1);}
	|                                       {CREATE_NODE($$,"OptTag",0,-1);}
	;
Tag:ID                                      {CREATE_NODE($$,"Tag",1,$1);}
	;
/*Declarators*/
VarDec:ID                                   {CREATE_NODE($$,"VarDec",1,$1);}
	|VarDec LB INT RB                       {CREATE_NODE($$,"VarDec",4,$1,$2,$3,$4);}
	|VarDec LB error RB                     {yyerror("Array size must be integer");}/*数组变量 应该出现整数 但未出现整数*/
	|VarDec LB INT error                    {yyerror("Missing ']' after array size");}
	;
FunDec:ID LP VarList RP                     {CREATE_NODE($$,"FunDec",4,$1,$2,$3,$4);}
	|ID LP RP                               {CREATE_NODE($$,"FunDec",3,$1,$2,$3);}
    |ID LP error RP                         {yyerror("invalid parameter list");}/*解析函数声明的形参列表遇到错误*/
	|ID LP VarList error                    {yyerror("Missing ')' after parameter list in function definition");}/*参数列表缺右括号*/
	//|ID LP error {yyerror("Missing 'parameter list' and ')' in function definition");}/*完全缺少参数列表*/
	;
VarList:ParamDec COMMA VarList              {CREATE_NODE($$,"VarList",3,$1,$2,$3);}
	|ParamDec                               {CREATE_NODE($$,"VarList",1,$1);}
	;
ParamDec:Specifier VarDec                   {CREATE_NODE($$,"ParamDec",2,$1,$2);}
    |Specifier error                        {yyerror("Missing parameter name");}/*缺少参数名*/
    ;
/*Statement  报错修改完成*/ 
CompSt:LC DefList StmtList RC                {CREATE_NODE($$,"CompSt",4,$1,$2,$3,$4);}
	|LC DefList StmtList error               {yyerror("Missing '}'");}                 /*缺少右侧}*/
	;
StmtList:Stmt StmtList                       {CREATE_NODE($$,"StmtList",2,$1,$2);}
	|                                        {CREATE_NODE($$,"StmtList",0,-1);}
	;
Stmt:Exp SEMI                                {CREATE_NODE($$,"Stmt",2,$1,$2);}
	|CompSt                                  {CREATE_NODE($$,"Stmt",1,$1);}
	|RETURN Exp SEMI                         {CREATE_NODE($$,"Stmt",3,$1,$2,$3);}
	|RETURN error SEMI                       {yyerror("Missing expression in return");} /*return 后没有返回值*/
    |IF LP Exp RP Stmt %prec LOWER_THAN_ELSE {CREATE_NODE($$,"Stmt",5,$1,$2,$3,$4,$5);}
    |IF LP Exp RP Stmt ELSE Stmt             {CREATE_NODE($$,"Stmt",7,$1,$2,$3,$4,$5,$6,$7);}
	|IF LP Exp error Stmt                    {yyerror("Missing ')'");}                 /*缺少右侧)*/
	|IF error Exp RP Stmt                    {yyerror("Missing '('");}                 /*缺少左侧(*/
	|WHILE LP Exp RP Stmt                    {CREATE_NODE($$,"Stmt",5,$1,$2,$3,$4,$5);}
	|WHILE LP Exp RP error                   {yyerror("Missing statement");}           /*while后缺语句体*/
	|Exp error                               {yyerror("Missing \";\"");}               /*缺;*/
    ;
/*Local Definitions   报错修改完成*/
DefList:Def DefList          {CREATE_NODE($$,"DefList",2,$1,$2);}
	|                        {CREATE_NODE($$,"DefList",0,-1);}
	;
Def:Specifier DecList SEMI   {CREATE_NODE($$,"Def",3,$1,$2,$3);}
	|Specifier DecList error {yyerror("Missing \";\"");}/*缺;*/
	;
DecList:Dec                  {CREATE_NODE($$,"DecList",1,$1);}
	|Dec COMMA DecList       {CREATE_NODE($$,"DecList",3,$1,$2,$3);}
	;
Dec:VarDec                   {CREATE_NODE($$,"Dec",1,$1);}
	|VarDec ASSIGNOP Exp     {CREATE_NODE($$,"Dec",3,$1,$2,$3);}
	|VarDec ASSIGNOP error   {yyerror("Missing expression after '='");}/*等号后缺表达式*/
	;
/*Expressions   报错修改完成*/
Exp:Exp ASSIGNOP Exp    {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
    // |error ASSIGNOP Exp {yyerror("Missing expression before '='");}
    |Exp ASSIGNOP error {yyerror("Missing expression after '='");}/*=后缺少表达式*/
	|Exp AND Exp        {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|Exp AND error      {yyerror("Missing expression after '&&'");}/*&&后缺少表达式*/
    |Exp OR Exp         {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|Exp OR error       {yyerror("Missing expression after '||'");}/*||后缺少表达式*/
    |Exp RELOP Exp      {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|Exp RELOP error    {yyerror("Missing expression after relop");}/*关系运算符后缺少表达式*/
    |Exp PLUS Exp       {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|Exp PLUS error     {yyerror("Missing expression after '+'");}/*+后缺少表达式*/
    |Exp MINUS Exp      {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|Exp MINUS error    {yyerror("Missing expression after '-'");}/*-后缺少表达式*/
    |Exp STAR Exp       {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|Exp STAR error     {yyerror("Missing expression after '*'");}/**后缺少表达式*/
    |Exp DIV Exp        {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|Exp DIV error      {yyerror("Missing expression after '/'");}/*/后缺少表达式*/
    |LP Exp RP          {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|LP Exp error       {yyerror("Missing ')'");}                 /*缺少)*/
    |MINUS Exp          {CREATE_NODE($$,"Exp",2,$1,$2);}
	|MINUS error        {yyerror("Missing operand after '-'");}/*一元运算符-后缺少表达式*/
    |NOT Exp            {CREATE_NODE($$,"Exp",2,$1,$2);}
	|NOT error          {yyerror("Missing operand after '!'");}/*一元运算符！后缺少表达式*/
    |ID LP Args RP      {CREATE_NODE($$,"Exp",4,$1,$2,$3,$4);}
	|ID LP Args error   {yyerror("Missing ')'");}              /*有参数无)*/
    |ID LP RP           {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|ID LP error        {yyerror("Missing ')'");}              /*无参数无)*/
    |Exp LB Exp RB      {CREATE_NODE($$,"Exp",4,$1,$2,$3,$4);}
	|Exp LB Exp error RB{yyerror("Missing \"]\"");}            /*有参数无]*/
    |Exp DOT ID         {CREATE_NODE($$,"Exp",3,$1,$2,$3);}
	|Exp DOT error      {yyerror("Missing field after '.'");}  /*访问成员名缺失*/
    |ID                 {CREATE_NODE($$,"Exp",1,$1);}
    |INT                {CREATE_NODE($$,"Exp",1,$1);}
    |FLOAT              {CREATE_NODE($$,"Exp",1,$1);}
    ;
Args:Exp COMMA Args     {CREATE_NODE($$,"Args",3,$1,$2,$3);}
    |Exp                {CREATE_NODE($$,"Args",1,$1);}
    ;
%%    