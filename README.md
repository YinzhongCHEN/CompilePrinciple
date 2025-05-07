# 编译原理大作业
## 环境需求
操作系统:Ubuntu Linux20.04
GCC:9.4.0
Flex:2.6.4
Bison:3.5.1
## 克隆项目
git clone https://github.com/Oscar-888/CompilePrinciple.git
cd CompilePrinciple
## 使用makefile构建
make
make test
make clean
## 使用命令构建
bison -d syn.y
flex lex.l
gcc -o cminus syn.tab.c lex.yy.c synTree.c -lfl
./cminus tests/test1.c
./cminus tests/test2.c
./cminus tests/test3.c


