default: help

update: ## Update modules
	@./scripts/update.sh

dirclean: ## Delete modules
	@./scripts/remove-modules.sh

help: ## Show interactive help
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: *
.NOTPARALLEL:
.ONESHELL: