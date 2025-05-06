# **********************************************************
# Makefile: Build (Bison→Flex→GCC) + Run tests/**/*.c → results/**
# **********************************************************

# ---------- 源文件 / 目标 ----------
BISON_SRC   := syn.y
FLEX_SRC    := lex.l
C_SRC       := synTree.c
TARGET      := cminus

CC          := gcc
LIBS        := -lfl
BISON       := bison
BISON_OPTS  := -d
FLEX        := flex

# ---------- 测试目录 ----------
TEST_DIR    := tests
RESULT_DIR  := results
TEST_EXT    := .c
OUT_EXT     := .txt

# ---------- 收集全部 .c 测试文件 ----------
TEST_SRC  := $(shell find $(TEST_DIR) -type f -name '*$(TEST_EXT)')
TEST_OUT  := $(patsubst $(TEST_DIR)/%$(TEST_EXT),\
                        $(RESULT_DIR)/%$(OUT_EXT),\
                        $(TEST_SRC))

# ---------- 伪目标 ----------
.PHONY: all build test clean

all: build                     # 默认只编译

# ---------------- 构建 ----------------
build: $(TARGET)

syn.tab.c syn.tab.h: $(BISON_SRC)
	$(BISON) $(BISON_OPTS) $<

lex.yy.c: $(FLEX_SRC)
	$(FLEX) $<

$(TARGET): syn.tab.c lex.yy.c $(C_SRC)
	$(CC) -o $@ syn.tab.c lex.yy.c $(C_SRC) $(LIBS)

# ---------------- 测试 ----------------
test: build $(TEST_OUT)
	@echo
	@echo "🎉  All tests finished.  See '$(RESULT_DIR)/' for outputs."

# ★★★★★ 关键：先保证根目录存在 ★★★★★
$(RESULT_DIR):
	@mkdir -p $@

# results/…/foo.txt ← tests/…/foo.c
# “| $(RESULT_DIR)” 表示 **顺序限定**：先建根目录再执行命令
results/%.txt : tests/%.c | $(RESULT_DIR)
	@echo "▶ $<"
	@mkdir -p $(dir $@)
	@./$(TARGET) $< > $@ 2>&1
	@echo "   ↳ $@"

# ---------------- 清理 ----------------
clean:
	@echo "🧹  Cleaning..."
	@rm -f syn.tab.[ch] lex.yy.c $(TARGET)
	@rm -rf $(RESULT_DIR)
