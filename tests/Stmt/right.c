int main() {
    { int i; i = 0; }
    if (x < 0) x = -x;
    if (x == 0) x = 1; else x = 2;
    while (i < 10) { i = i + 1; }
    return x;
    foo();
  }