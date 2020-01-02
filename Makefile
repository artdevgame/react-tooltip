NODE_BIN     = node_modules/.bin
EXAMPLE_DIST = example/dist
EXAMPLE_SRC  = example/src
STANDALONE   = standalone
SRC          = src
DIST         = dist
TEST         = test/*.test.js
MOCHA_OPTS   = --compilers js:babel-core/register --require test/setup.js -b --timeout 20000 --reporter spec

lint:
	@echo Linting...
	standard --verbose | $(NODE_BIN)/snazzy src/index.js

convertCSS:
	@echo Converting css...
	@node bin/transferSass.js

genStand:
	@echo Generating standard...
	@rm -rf $(STANDALONE) && mkdir $(STANDALONE)
	browserify -t babelify -t browserify-shim $(SRC)/index.js --standalone ReactTooltip -o $(STANDALONE)/react-tooltip.js
	browserify -t babelify -t browserify-shim $(SRC)/index.js --standalone ReactTooltip | $(NODE_BIN)/uglifyjs > $(STANDALONE)/react-tooltip.min.js

devJS:
	watchify -t babelify $(EXAMPLE_SRC)/index.js -o $(EXAMPLE_DIST)/index.js -dv

devCSS:
	node-sass $(EXAMPLE_SRC)/index.scss $(EXAMPLE_DIST)/index.css
	node-sass $(SRC)/index.scss $(EXAMPLE_DIST)/style.css
	node-sass -w $(EXAMPLE_SRC)/index.scss $(EXAMPLE_DIST)/index.css

deployExample:
	browserify -t babelify $(EXAMPLE_SRC)/index.js -o $(EXAMPLE_DIST)/index.js -dv
	node-sass $(EXAMPLE_SRC)/index.scss $(EXAMPLE_DIST)/index.css
	node-sass $(SRC)/index.scss $(EXAMPLE_DIST)/style.css

devServer:
	@echo Listening 8888...
	http-server example -p 8888 -s

dev:
	@echo starting dev server...
	@rm -rf $(EXAMPLE_DIST)
	@mkdir -p $(EXAMPLE_DIST)
	@make convertCSS
	concurrently --kill-others "make devJS" "make devCSS" "make devServer"

deployJS:
	@echo Generating deploy JS files...
	babel $(SRC) --out-dir $(DIST)

deploy: lint
	@echo Deploy...
	@rm -rf dist && mkdir dist
	@rm -rf $(EXAMPLE_DIST) && mkdir -p $(EXAMPLE_DIST)
	@make deployExample
	@make convertCSS
	@make deployJS
	@make genStand
	@echo success!

.PHONY: lint convertCSS genStand devJS devCSS devServer dev deployExample deployJS deployCSS deploy
