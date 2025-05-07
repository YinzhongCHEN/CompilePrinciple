#include "synTree.h"
extern void yyrestart(FILE *inputfile);
extern int yyparse(void);
// 用于遍历
int i;
//语法树创建
Ast newAst(char *name, int num, ...)
{
    va_list args;
    // 1) 分配并初始化节点
    tnode father = (tnode)malloc(sizeof(struct ASTNode));
    if (!father) {
        yyerror("malloc failed in newAst");
        exit(1);
    }
    father->name   = name;
    father->fchild = NULL;
    father->next   = NULL;

    // 2) 读取可变参数
    va_start(args, num);
    if (num > 0) {
        // 2.1) 第一个孩子
        tnode child = va_arg(args, tnode);
        setChildTag(child);
        father->fchild = child;
        father->line   = child->line;

        // 2.2) 其余孩子串成兄弟链
        tnode prev = child;
        for (int k = 1; k < num; ++k) {
            tnode cur = va_arg(args, tnode);
            prev->next = cur;
            setChildTag(cur);
            prev = cur;
        }
        // 2.3) 断开链尾
        prev->next = NULL;
    } else {
        // 3) 叶节点或 ε 节点，num==0 时传入的是行号
        int lineno = va_arg(args, int);
        father->line = lineno;
        if (strcmp(name, "ID") == 0 || strcmp(name, "TYPE") == 0) {
            father->id_type = strdup(yytext);
        } else if (strcmp(name, "INT") == 0) {
            father->intval = atoi(yytext);
        } else {  // FLOAT
            father->fltval = atof(yytext);
        }
    }
    va_end(args);
    return father;
}

// 先序遍历语法树并且输出各个节点行号和类型
void Preorder(Ast ast, int level) {
    if (!ast || ast->line == -1) return;
    // if (!ast ) return;

    // 缩进
    for (int k = 0; k < level; ++k) printf("  ");

    // 叶子节点：fchild==NULL
    if (ast->fchild == NULL) {
        // 特殊词素
        if (!strcmp(ast->name,"ID")||!strcmp(ast->name,"TYPE"))
            printf("%s: %s", ast->name, ast->id_type);
        else if (!strcmp(ast->name,"INT"))
            printf("INT: %d", ast->intval);
        else if (!strcmp(ast->name,"FLOAT"))
            printf("FLOAT: %f", ast->fltval);
        else
            // 其它符号只打印名字，不带行号
            printf("%s", ast->name);
    }
    else {
        // 非叶子才打印行号
        printf("%s (%d)", ast->name, ast->line);
    }
    printf("\n");

    Preorder(ast->fchild, level+1);
    Preorder(ast->next,  level);
}


// 错误处理
void yyerror(char *msg)
{
        // 如果是 Bison 内置的默认提示，则忽略不显示
        if (strcmp(msg, "syntax error") == 0) {
            return;
        }
    hasFault = 1;
    //fprintf(stderr, "Error type B at Line %d: %s\n", yylineno, msg);
    printf("Error type B at line %d:%s.\n",yylineno,msg);
}
// 设置节点打印状态 该节点为子节点
void setChildTag(tnode node)
{
    int i;
    for (i = 0; i < nodeNum; i++)
    {
        if (nodeList[i] == node)
        {
            nodeIsChild[i] = 1;
        }
    }
}

// 主函数 扫描文件并分析
int main(int argc, char **argv)
{
    int j;
    //printf("start analysis\n");
    if (argc < 2)
    {
        return 1;
    }
    for (i = 1; i < argc; i++)
    {
        // 初始化节点记录列表
        nodeNum = 0;
        memset(nodeList, 0, sizeof(tnode) * 5000);
        memset(nodeIsChild, 0, sizeof(int) * 5000);
        hasFault = 0;

        FILE *f = fopen(argv[i], "r");
        if (!f)
        {
            perror(argv[i]);
            return 1;
        }
        yyrestart(f);
        yyparse();
        fclose(f);

        // 遍历所有非子节点的节点
        if (hasFault)
            continue;
        for (j = 0; j < nodeNum; j++)
        {
            if (nodeIsChild[j] != 1)
            {
                Preorder(nodeList[j], 0);
            }
        }
    }
}
