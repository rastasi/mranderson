# -----------------------------------------
# Makefile – TIC-80 project builder
# Usage:
#   make PROJECT=mranderson
#   make build PROJECT=mranderson
#   make watch PROJECT=mranderson
#   make export PROJECT=mranderson
# -----------------------------------------

ifndef PROJECT
$(error Specify the project name: make PROJECT=name)
endif

ORDER      = $(PROJECT).inc
OUTPUT     = $(PROJECT).lua
OUTPUT_ZIP = $(PROJECT).html.zip
OUTPUT_TIC = $(PROJECT).tic

SRC_DIR    = inc
SRC = $(shell sed 's|^|$(SRC_DIR)/|' $(ORDER))

all: build

build: $(OUTPUT)
	@echo "==> Build complete: $(OUTPUT)"

$(OUTPUT): $(SRC) $(ORDER)
	@echo "==> Building $(OUTPUT)..."
	@rm -f $(OUTPUT)
	@while read f; do \
		echo "-- FILE: $$f" >> $(OUTPUT); \
		cat "$(SRC_DIR)/$$f" >> $(OUTPUT); \
		echo "\n" >> $(OUTPUT); \
	done < $(ORDER)
	@echo "==> Done."

export: $(OUTPUT)
	@echo "==> TIC-80 export..."
	tic80 --cli --skip --fs=. \
		--cmd="load $(OUTPUT) & save $(PROJECT) & export html $(PROJECT).html & exit"
	@echo "==> HTML ZIP: $(OUTPUT_ZIP)"
	@echo "==> TIC: $(OUTPUT_TIC)"

watch:
	@echo "==> Watching project: $(PROJECT)"
	fswatch -o $(SRC_DIR) $(ORDER) | while read; do make build PROJECT=$(PROJECT); done
