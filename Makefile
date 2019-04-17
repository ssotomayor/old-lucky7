
REPORTER = nyan
UNIT_TESTS = $(shell find tests/unit -name "*.coffee")

test: test-unit

test-unit:
	@NODE_ENV=test ./node_modules/.bin/mocha -u bdd \
		--reporter $(REPORTER) \
		--compilers coffee:coffee-script/register \
		$(UNIT_TESTS)

test-w:
	@NODE_ENV=test ./node_modules/.bin/mocha -u bdd -b \
		--reporter $(REPORTER) \
		--compilers coffee:coffee-script/register \
		--watch \
		--growl \
		$(UNIT_TESTS)

test-one:
	@NODE_ENV=test ./node_modules/.bin/mocha -u bdd -b \
		--reporter $(REPORTER) \
		--compilers coffee:coffee-script/register \
		$f

test-one-w:
	@NODE_ENV=test ./node_modules/.bin/mocha -u bdd -b \
		--reporter $(REPORTER) \
		--compilers coffee:coffee-script/register \
		--watch \
		--growl \
		$f

.PHONY: test-unit test-w test-one