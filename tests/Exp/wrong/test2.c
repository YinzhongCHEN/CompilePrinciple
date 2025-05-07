// 测试 “Exp AND Exp” 和 “Exp OR Exp” 中缺右操作数
int main() {
    a && ;      // 缺右操作数，应报 “Missing operand after '&&'”
    a || ;      // 缺右操作数，应报 “Missing operand after '||'”

    return 0;
}
