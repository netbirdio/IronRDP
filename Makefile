# IronRDP WASM Build for NetBird

BUILD_DIR := build
OUTPUT := $(BUILD_DIR)/ironrdp-pkg
WASM_OUTPUT := $(OUTPUT)/ironrdp_web_bg.wasm
IRONRDP_SOURCES := crates/ironrdp-web/src crates/ironrdp-web/Cargo.toml

.PHONY: all
all: build

.PHONY: build
build: check-rebuild

# Check if rebuild is needed based on source changes
.PHONY: check-rebuild
check-rebuild:
	@if [ ! -f "$(WASM_OUTPUT)" ]; then \
		echo "IronRDP output not found, building..."; \
		$(MAKE) force-build; \
	else \
		REBUILD_NEEDED=0; \
		for src in $(IRONRDP_SOURCES); do \
			if [ -e "$$src" ] && find "$$src" -newer "$(WASM_OUTPUT)" -print -quit | grep -q .; then \
				echo "IronRDP sources changed, rebuilding..."; \
				REBUILD_NEEDED=1; \
				break; \
			fi; \
		done; \
		if [ "$$REBUILD_NEEDED" = "1" ]; then \
			$(MAKE) force-build; \
		else \
			echo "IronRDP unchanged, skipping build..."; \
		fi \
	fi

# Force build without checking
.PHONY: force-build
force-build:
	@echo "Building IronRDP WASM module..."
	@mkdir -p $(BUILD_DIR)
	@cd crates/ironrdp-web && \
		wasm-pack build --release --target web --out-dir ../../$(OUTPUT) 2>&1 | tail -5

.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	cargo clean

.PHONY: help
help:
	@echo "IronRDP WASM Build for NetBird"
	@echo ""
	@echo "Available targets:"
	@echo "  make              - Build WASM module if sources changed (default)"
	@echo "  make build        - Build WASM module if sources changed"
	@echo "  make force-build  - Force rebuild regardless of changes"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make help         - Show this help message"