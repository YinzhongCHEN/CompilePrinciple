/*第一部分 头文件和变量*/
%{
	#include <stdlib.h>
	#include <stdio.h>
	#include"synTree.h"
	#include"syn.tab.h"
	#define RET_TOK(tok) \
    do { yylval.astNode = newAst(#tok, 0, yylineno); return tok; } while(0)
	int comment_begin = 0;
%}
/*flex属性,记录符号所在行号*/
%option yylineno
%x COMMENT
/*第二部分 定义正则表达式*/
/*十进制*/
INT 0|[1-9][0-9]*
/*十六进制*/
INT_HEX 0[xX][a-fA-F0-9]+
/*八进制*/
INT_OCT 0[1-7][0-7]*
/*二进制*/
INT_BIN 0[bB][01]+
/*浮点数*/
FLOAT {INT}\.[0-9]+
/*科学计数法*/
SCIENCE (([0-9]+\.[0-9]*)|([0-9]*\.[0-9]+)|INT)[Ee][-+]?[0-9]+
/*标识符*/
ID [a-z_A-Z][a-z_A-Z0-9]*
/*关键字*/
STRUCT struct
RETURN return
IF if
ELSE else
WHILE while
TYPE int|float

/*部分符号*/
/*标点*/
SEMI  ;
COMMA ,
/*运算*/
ASSIGNOP  =
PLUS  \+
MINUS \-
STAR  \*
DIV   \/
AND   &&
OR    \|\|
DOT   \.
NOT   \!
/*括号*/
LP    \(
RP    \)
LB    \[
RB    \]
LC    \{
RC    \}
RELOP >|<|>=|<=|==|!=
/*其它字符*/
/*注释*/
LINE_COMMENT "//".*
/*空白符*/
SPACE [ \f\n\r\t\v]+
/*未定义字符*/
AERROR .
/*十六进制错误*/
INT_HEX_ERROR 0[xX][a-fA-F0-9]*[g-zG-Z]+[a-fA-F0-9]*
/*八进制错误*/
INT_OCT_ERROR 0[0-7]*[89]+[0-7]*
/*二进制错误*/
INT_BIN_ERROR 0[bB][01]*[2-9]+[01]*

/* 不完整科学计数法错误：如 "1.05e" 或 "1.05e+" 后面直接遇到换行/空白/分号等 */
SCIENCE_ERROR_INCOMPLETE  (([0-9]+\.[0-9]*)|([0-9]*\.[0-9]+)|{INT})[Ee][-+]?[[:space:](),{}\[\]]?
/* 非法字符科学计数法错误：如 "1.05eee", "1.05e++2", "1.05e+abc" */
SCIENCE_ERROR_ILLEGAL (\.[Ee][-+]?[0-9]+)|(([0-9]+\.[0-9]*)|([0-9]*\.[0-9]+)|{INT})[Ee][-+]?[^0-9;\s(){}\[\]][^;\s(){}\[\]]*
/*第三部分 操作 action 这里面的注释必须顶格一个空格*/
%%
 /*跳过空白和注释*/
{SPACE} {}
{LINE_COMMENT} {}
"/*" {comment_begin = yylineno;BEGIN(COMMENT);}
"*/" {hasFault = 1;printf("Error type A at Line %d: MALFORMED_COMMENT \"%s\"\n", yylineno, yytext);}
<COMMENT>"*/" {BEGIN(INITIAL);}
<COMMENT>"/*" {hasFault = 1;printf("Error type A at Line %d: NESTED_COMMENT \"%s\"\n", yylineno, yytext);}
<COMMENT>\n {}
<COMMENT>[^/*\n]+ {}
<COMMENT>[/*] {}
 /*未终结注释错误*/
<COMMENT><<EOF>> {
	hasFault = 1;
	printf("Error type A at Line %d: UNTERMINATED_COMMENT (started at Line %d)\n", yylineno, comment_begin);
	BEGIN(INITIAL);
	yyterminate();
}
 /*关键字*/
{TYPE}          RET_TOK(TYPE);
{STRUCT}        RET_TOK(STRUCT);
{RETURN}        RET_TOK(RETURN);
{IF}            RET_TOK(IF);
{ELSE}          RET_TOK(ELSE);
{WHILE}         RET_TOK(WHILE);
 /*数字类型错误*/
{INT_HEX_ERROR} {hasFault = 1;printf("Error type A at Line %d: INT_HEX_ERROR \"%s\"\n",yylineno,yytext);}
{INT_OCT_ERROR} {hasFault = 1;printf("Error type A at Line %d: INT_OCT_ERROR \"%s\"\n",yylineno,yytext);}
{INT_BIN_ERROR} {hasFault = 1;printf("Error type A at Line %d: INT_BIN_ERROR \"%s\"\n",yylineno,yytext);}
 /*数字类型表示*/
{INT}           RET_TOK(INT);
{FLOAT}         RET_TOK(FLOAT);
 /*标点*/
{SEMI}          RET_TOK(SEMI);
{COMMA}         RET_TOK(COMMA);
 /*运算符*/
{ASSIGNOP}      RET_TOK(ASSIGNOP);
{PLUS}          RET_TOK(PLUS);
{MINUS}         RET_TOK(MINUS);
{STAR}          RET_TOK(STAR);
{DIV}           RET_TOK(DIV);
{AND}           RET_TOK(AND);
{OR}            RET_TOK(OR);
{DOT}           RET_TOK(DOT);
{NOT}           RET_TOK(NOT);
{RELOP}         RET_TOK(RELOP);
 /*括号*/
{LP}            RET_TOK(LP);
{RP}            RET_TOK(RP);
{LB}            RET_TOK(LB);
{RB}            RET_TOK(RB);
{LC}            RET_TOK(LC);
{RC}            RET_TOK(RC);
 /*标识符*/
{ID}            RET_TOK(ID);
 /*错误*/
{AERROR} {hasFault = 1;printf("Error type A at Line %d: Mysterious charachter \"%s\"\n",yylineno,yytext);}
 /*科学计数法错误 */
{SCIENCE_ERROR_INCOMPLETE} {hasFault = 1;printf("Error type A at Line %d: SCIENCE_ERROR_INCOMPLETE \"%s\"\n", yylineno, yytext);}
{SCIENCE_ERROR_ILLEGAL} {hasFault = 1;printf("Error type A at Line %d: SCIENCE_ERROR_ILLEGAL \"%s\"\n", yylineno, yytext);}
%%
/*第四部分*/
int yywrap()
{
    return 1;
}

