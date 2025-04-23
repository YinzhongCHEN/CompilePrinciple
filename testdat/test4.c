int main() {
    int x;
    int y;
    int z;
    x = 5;
    y = 3;
    z = x + y;
    if (z > 10) {
        z = z - 10;
    } else {
        z = z + 10;
    }
    while (z > 0) {
        z = z - 1;
    }
    return 0;
}