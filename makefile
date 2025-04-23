# **********************************************************
# Makefile: Build (Bison→Flex→GCC) + Run testdat/*.c → results
# **********************************************************

# —— 可调变量 —— 
BISON_SRC     := syn.y
FLEX_SRC      := lex.l
C_SRC         := synTree.c
TARGET        := cminus

CC            := gcc
LIBS          := -lfl

BISON         := bison
BISON_OPTS    := -d
FLEX          := flex

# 测试相关
TEST_DIR      := testdat
RESULT_DIR    := results
TEST_SUFFIX   := .c
OUT_SUFFIX    := .out

# 收集所有测试源和对应结果文件
TEST_SOURCES  := $(wildcard $(TEST_DIR)/*$(TEST_SUFFIX))
TEST_RESULTS  := $(patsubst $(TEST_DIR)/%$(TEST_SUFFIX),$(RESULT_DIR)/%$(OUT_SUFFIX),$(TEST_SOURCES))

# —— 伪目标 —— 
.PHONY: all build test clean

# 默认目标：只做编译
all: build

# ---- 构建步骤 ----
build: $(TARGET)

# Bison 生成 syn.tab.c/h
syn.tab.c syn.tab.h: $(BISON_SRC)
	$(BISON) $(BISON_OPTS) $<

# Flex 生成 lex.yy.c
lex.yy.c: $(FLEX_SRC)
	$(FLEX) $<

# 最终链接
$(TARGET): syn.tab.c lex.yy.c $(C_SRC)
	$(CC) -o $@ syn.tab.c lex.yy.c $(C_SRC) $(LIBS)

# ---- 测试步骤 ----
# 先确保 build，再为每个测试源生成结果文件
test: build $(TEST_RESULTS)
	@echo
	@echo "🎉 All tests finished. See $(RESULT_DIR)/ for outputs."

# 运行单个测试
# e.g. testdat/foo.c → results/foo.out
$(RESULT_DIR)/%$(OUT_SUFFIX): $(TEST_DIR)/%$(TEST_SUFFIX) | $(RESULT_DIR)
	@echo "▶ Running test: $<"
	@./$(TARGET) $< > $@ 2>&1
	@echo "   ↳ output → $@"

# 确保 results 目录存在
$(RESULT_DIR):
	mkdir -p $@

# ---- 清理 ----
clean:
	@echo "🧹 Cleaning up..."
	rm -f syn.tab.[ch] lex.yy.c $(TARGET)
	rm -rf $(RESULT_DIR)

