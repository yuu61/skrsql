# Makefile 
# Refactored with improved checks, variables, and phony targets

# --- Configuration ---
URL      := https://github.com/miyabilink/sukkiri-sql4-codes/releases/latest/download/sukkiri-sql4-codes.zip
FILE     := $(notdir $(URL))
DEST_DIR := /usr/local/share/ssql
BIN_DIR  := /usr/local/bin
TESTDB   := testdb-$$

.PHONY: all setup check download clean install uninstall

# Default target
all: setup

# Verify psql and DB creation privileges
check:
	@echo -n "Checking prerequisites... "
	@command -v psql >/dev/null 2>&1 || { echo "[致命的] psql が PATH に見つかりません"; exit 1; }
	@createdb $(TESTDB) >/dev/null 2>&1 && dropdb $(TESTDB) >/dev/null 2>&1 \
		|| { echo "[致命的] パスワードなしで DB を作成できません"; exit 1; }
	@echo "OK"

# Quick sanity check before install
setup: check
	@echo "チェック完了。'sudo make install' を実行してください"

# Download the release archive if missing
download: $(FILE)

$(FILE):
	@echo "$(URL) をダウンロード中..."
	@curl -sfLo $@ $(URL)

# Install files: unzip contents directly, set read-only permissions, install skrsql
install: download
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "[致命的] インストールにはルート権限が必要です。'sudo make install'"; \
		exit 1; \
	fi
	@echo "$(DEST_DIR) に展開中..."
	@mkdir -p $(DEST_DIR) $(BIN_DIR)
	@unzip -o -q $(FILE) -d $(DEST_DIR)
	@echo "コピー完了: $(DEST_DIR) 以下に展開されたファイルをそのまま配置"

	# ファイル・ディレクトリを読み取り専用に設定
	@find $(DEST_DIR) -type d -exec chmod 755 {} \;
	@find $(DEST_DIR) -type f -exec chmod 644 {} \;

	# スクリプト本体を skrsql として配置
	@install -m 0755 bin/skrsql $(BIN_DIR)/skrsql

	# Bash Completion をインストール
	@install -m 0644 bin/bash_completion /etc/bash_completion.d/skrsql

# Cleanup downloaded archive
clean:
	@rm -f $(FILE)

# Remove installation and binary
uninstall:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "[致命的] アンインストールにはルート権限が必要です。'sudo make uninstall'"; \
		exit 1; \
	fi
	@echo "アンインストール中..."
	@rm -rf $(DEST_DIR)
	@rm -f $(BIN_DIR)/skrsql
	@rm -f /etc/bash_completion.d/skrsql