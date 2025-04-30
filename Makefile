# Makefile v3.8.0
# Refactored with improved checks, variables, and phony targets

# --- Configuration ---
URL := https://github.com/miyabilink/sukkiri-sql4-codes/releases/latest/download/sukkiri-sql4-codes.zip
FILE := $(notdir $(URL))
DEST_DIR := /usr/local/share/ssql
BIN_DIR := /usr/local/bin
TESTDB := testdb-$$$

.PHONY: all setup check download clean install uninstall

# Default target
all: setup

# Quick sanity check before install
setup: check
	@echo "チェック完了、'make install' を実行してください"

# Verify psql and DB creation privileges
check:
	@echo -n "Checking prerequisites... "
	@command -v psql >/dev/null 2>&1 || { echo "[致命的] psqlがPATHに見つかりません"; exit 1; }
	@createdb $(TESTDB) >/dev/null 2>&1 && dropdb $(TESTDB) >/dev/null 2>&1 || { echo "[FATAL] パスワードなしでDBを作成できません"; exit 1; }
	@echo "OK"

# Download the release archive if missing
download: $(FILE)

$(FILE):
	@echo "$(URL) をダウンロード中..."
	@curl -sfLo $@ $(URL)

# Cleanup downloaded archive
clean:
	@rm -f $(FILE)

# Install files, create directories, and symlinks
install: download
	@echo "$(DEST_DIR) にインストール中..."
	@install -d $(DEST_DIR) $(BIN_DIR)
	@unzip -o -q $(FILE) -d $(DEST_DIR)
	@for file in $(DEST_DIR)/setup/chapae/*[0-9][0-9][0-9][0-9].sql; do \
		chap=$$(basename $$file .sql | cut -c1-2); \
		target=$(DEST_DIR)/chap$$chap; \
		install -d $$target; \
		ln -svf "$$file" $$target/; \
	done
	@if [ -n "$(LIST_SRC)" ]; then \
		install -m 0755 "$(LIST_SRC)" "$(BIN_DIR)/list"; \
	else \
		echo "[警告] 'list' スクリプトが $(DEST_DIR); 以下に見つかりません。アーカイブの内容を確認してください"; \
	fi
	@cd $(BIN_DIR) && for cmd in list can q drill; do ln -svf list $$cmd; done

# Remove installation and symlinks
uninstall:
	@echo "アンインストール中..."
	@rm -rf $(DEST_DIR)
	@cd $(BIN_DIR) && for cmd in list can q drill; do rm -f $$cmd; done
