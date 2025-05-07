# 编译原理大作业
## 环境需求
OS: Ubuntu Linux 20.04  
GCC: 9.4.0  
Flex: 2.6.4  
Bison: 3.5.1  
## 克隆项目
```bash
git https://github.com/YinzhongCHEN/CompilePrinciple.git  
cd CompilePrinciple
```
## 使用makefile构建
```bash
# 编译运行词法/语法分析器
make
# 执行各测试文件  
make test  
# 清除生成文件
make clean
```
## 使用命令构建
```bash
bison -d syn.y  
flex lex.l  
gcc -o cminus syn.tab.c lex.yy.c synTree.c -lfl  
# 测试三个样例
./cminus tests/test1.c  
./cminus tests/test2.c  
./cminus tests/test3.c
```


