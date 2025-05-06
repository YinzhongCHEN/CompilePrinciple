int;                                // Specifier SEMI，空语句合法
int global1, global2;               // 全局变量定义
struct { int x, y; };               // 匿名结构体定义
struct Point { int x, y; };         // 带标签的结构体定义
struct Point p1, p2;                // 使用已定义结构体
float foo() { return 0.0; }         // 无参函数定义
int bar(int a, float b[10]) {       // 带参函数定义
    return a + (int)b[0];
}
