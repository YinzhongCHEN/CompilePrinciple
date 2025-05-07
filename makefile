# 源文件和目标文件
BISON_SRC   := syn.y
FLEX_SRC    := lex.l
C_SRC       := synTree.c
TARGET      := cminus

CC          := gcc
LIBS        := -lfl
BISON       := bison
BISON_OPTS  := -d
FLEX        := flex

# 测试文件和结果输出目录
TEST_DIR    := tests
RESULT_DIR  := results
TEST_EXT    := .c
OUT_EXT     := .txt

# 收集所有待测试的.c文件
TEST_SRC  := $(shell find $(TEST_DIR) -type f -name '*$(TEST_EXT)')
TEST_OUT  := $(patsubst $(TEST_DIR)/%$(TEST_EXT),\
                        $(RESULT_DIR)/%$(OUT_EXT),\
                        $(TEST_SRC))
.PHONY: all build test clean
all: build                     
# build 过程
build: $(TARGET)

syn.tab.c syn.tab.h: $(BISON_SRC)
	$(BISON) $(BISON_OPTS) $<

lex.yy.c: $(FLEX_SRC)
	$(FLEX) $<

$(TARGET): syn.tab.c lex.yy.c $(C_SRC)
	$(CC) -o $@ syn.tab.c lex.yy.c $(C_SRC) $(LIBS)

# 执行测试文件并输出到对应目录
test: build $(TEST_OUT)
	@echo
	@echo "🎉  All tests finished.  See '$(RESULT_DIR)/' for outputs."
$(RESULT_DIR):
	@mkdir -p $@

# 将测试文件的输出保存到.txt文件中并输出
results/%.txt : tests/%.c | $(RESULT_DIR)
	@echo "▶ $<"
	@mkdir -p $(dir $@)
	@./$(TARGET) $< > $@ 2>&1
	@echo "   ↳ $@"

# 清除所有生成的文件和代码
clean:
	@echo "🧹  Cleaning..."
	@rm -f syn.tab.[ch] lex.yy.c $(TARGET)
	@rm -rf $(RESULT_DIR)
