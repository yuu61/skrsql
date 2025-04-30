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
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "[致命的] インストールにはルート権限が必要です。'sudo make install'"; \
		exit 1; \
	fi
	@echo "$(DEST_DIR) にインストール中..."
	@mkdir -p $(DEST_DIR) $(BIN_DIR)
	@unzip -o -q $(FILE) -d $(DEST_DIR)
	@for file in $(DEST_DIR)/setup/chapae/*[0-9][0-9][0-9][0-9].sql; do \
	chap=$$(basename $$file .sql | cut -c1-2); \
	target=$(DEST_DIR)/setup/chap$$chap; \
		ln -svf "$$file" $$target/; \
	done
	@install -m 0755 bin/list $(BIN_DIR)/
	@@cd $(BIN_DIR) && for cmd in can q drill; do ln -svf list $$cmd; done

# Remove installation and symlinks
uninstall:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "[FATAL] アンインストールにはルート権限が必要です。'sudo make uninstall'"; \
		exit 1; \
	fi
	@echo "アンインストール中..."
	@rm -rf $(DEST_DIR)
	@cd $(BIN_DIR) && for cmd in list can q drill; do rm -f $$cmd; done
