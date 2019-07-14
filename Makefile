PROJECT_NAME := goWebBoilerplate
PK := github.com/withnic/${PROJECT_NAME}
PKG := "${PK}"
PKG_LIST := $(shell go list ${PKG}/... | grep -v /vendor/)
GO_GET := GO111MODULE=off go get
GO_MOD := GO111MODULE=on go mod
GO := GO111MODULE=on go
GO_BUILD := go build
BINARY := app
MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
BUILD_TIME=`date +%FT%T%z`
VERSION := 0.0.1
REVISION := $(shell git rev-parse --short HEAD)
LDFLAGS := -ldflags="-s -w -X \"main.Version=$(VERSION)\" -X \"main.Revision=$(REVISION)\" -X \"main.BuildTime=$(BUILD_TIME)\"
EXTLDFLAGS := -extldflags \"-static\""

# ANSI color
RED=\033[31m
GREEN=\033[32m
RESET=\033[0m

COLORIZE_PASS=sed ''/PASS/s//$$(printf "$(GREEN)PASS$(RESET)")/''
COLORIZE_FAIL=sed ''/FAIL/s//$$(printf "$(RED)FAIL$(RESET)")/''

.DEFAULT_GOAL := help

.PHONY: dev
dev: ## Setup develop envelopment
	cp -P git/hooks/pre-commit .git/hooks/pre-commit
	cp -p git/hooks/post-commit .git/hooks/post-commit
	cp -p git/hooks/pre-push .git/hooks/pre-push
	git config commit.template git/commit_template

.PHONY: setup
setup: ## setup using bin
	$(GO_GET) github.com/mvdan/unparam
	$(GO_GET) golang.org/x/lint/golint
	$(GO_GET) golang.org/x/tools/cmd/goimports
	$(GO_GET) github.com/kisielk/errcheck
	$(GO_GET) honnef.co/go/tools/cmd/staticcheck
	$(GO_GET) golang.org/x/tools/go/analysis/passes/shadow/cmd/shadow
	$(GO_GET) github.com/fzipp/gocyclo
	$(GO_GET) gitlab.com/opennota/check/cmd/aligncheck
	$(GO_GET) github.com/securego/gosec/cmd/gosec
	$(GO_GET) github.com/haya14busa/reviewdog/cmd/reviewdog

.PHONY: build
build: ## Build binary
	$(GO_BUILD) ${LDFLAGS} ${EXTLDFLAGS} -o ${BINARY} .

.PHONY: list
list: ## Display list modules
	@$(GO) list -m all

.PHONY: up_list
up_list: ## Display updatable modules list
	@$(GO) list -u -m all

.PHONY: unparam
unparam: ## Find unused function params.
	@unparam ${PKG_LIST}

.PHONY: pkglint
pkglint: ## Lint package name
	@${MAKEFILE_DIR}/scripts/pkglint.sh ${PKG_LIST}

.PHONY: lint
lint: ## Find invalid code format.
	@golint --set_exit_status ${PKG_LIST}

.PHONY: errcheck
errcheck: ## Find unhandling error.
	@errcheck ${PKG_LIST}

.PHONY: staticcheck
staticcheck: ## Find something wrong.
	@staticcheck ${PKG_LIST}

.PHONY: shadow
shadow: ## Shadow checks variable shadowing without err.
	@! go vet -vettool=$(which shadow) ${PKG_LIST} 2>&1 | grep -vE '(declaration of "err" shadows|^vet: cannot process directory \.git|^#)'

.PHONY: cyclo
cyclo: ## Reports cyclomatic complexity.
	@gocyclo -over 10 ${PKG_LIST}

.PHONY: aligncheck
aligncheck: ## Reports struct size.
	@aligncheck ${PKG_LIST}

.PHONY: sec
sec: ## Reports unsafe code.
	@gosec .

.PHONY: pretest
pretest: pkglint lint cyclo aligncheck shadow unparam errcheck staticcheck

.PHONY: t
t: ## Test dir path. usage make t DIR=foo
	@GO_ENV=test go test -v ${PK}/${DIR} | $(COLORIZE_PASS) | $(COLORIZE_FAIL)

.PHONY: test
test: pretest ## Test all
	@GO_ENV=test go test -v ${PKG_LIST} | $(COLORIZE_PASS) | $(COLORIZE_FAIL)

help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
