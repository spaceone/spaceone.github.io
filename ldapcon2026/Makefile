THEME  := themes
SLIDES := slides.md
HTML_SLIDES := $(SLIDES:.md=.html)
# Pinned so every build uses the same, reviewed Marp CLI release.
MARP_VERSION := 4.5.1
# MARP   := npx @marp-team/marp-cli@$(MARP_VERSION) --theme-set $(THEME) --allow-local-files
MARP   := nodejs /usr/local/lib/node_modules/node/bin/marp --server --theme-set $(THEME) --allow-local-files

# Same builds without a local Node.js, in the official Marp CLI image.
# MARP_USER makes the generated files belong to you, not root.
DOCKER_RUN  := docker run --rm --init -v "$(CURDIR)":/home/marp/app -e MARP_USER="$$(id -u):$$(id -g)" -e LANG="$(LANG)"
DOCKER_MARP := marpteam/marp-cli:v$(MARP_VERSION) --theme-set $(THEME) --allow-local-files

build:
	$(MARP) -o deck.html $(SLIDES)

pdf:
	$(MARP) --pdf  $(SLIDES)

pptx:
	$(MARP) --pptx  $(SLIDES)

watch:
	$(MARP)  --watch --preview $(SLIDES)

serve:
	$(MARP) -s $(SLIDES)

docker-html:
	$(DOCKER_RUN) $(DOCKER_MARP) --html -o $(HTML_SLIDES) $(SLIDES)
	sed -i 's#src="https://cdn\.jsdelivr\.net/gh/jdecked/twemoji@17\.0\.3/assets#src="assets#g' -- $(HTML_SLIDES)
	sed -i 's#url("https://fonts\.googleapis\.com/css2?family=Open+Sans:ital,wght@0,400;0,600;0,700;0,800;1,400&display=swap")#url("images/fonts/open-sans.css")#g' -- $(HTML_SLIDES)
	grep -o 'src="[^"]*"' -- $(HTML_SLIDES) | sort -u
	grep -o 'href="[^"]*"' -- $(HTML_SLIDES) | sort -u
	grep -o 'url\([^)]*\)' -- $(HTML_SLIDES) | sort -u

docker-build:
	$(DOCKER_RUN) $(DOCKER_MARP) -o deck.html $(SLIDES)

docker-pdf:
	$(DOCKER_RUN) $(DOCKER_MARP) --pdf  $(SLIDES)

docker-pptx:
	$(DOCKER_RUN) $(DOCKER_MARP) --pptx  $(SLIDES)

# Live preview at http://localhost:8080, reloads as you save.
docker-serve:
	$(DOCKER_RUN) -p 127.0.0.1:8080:8080 -p 127.0.0.1:37717:37717 $(DOCKER_MARP) --server  .

.PHONY: build pdf pptx watch docker-build docker-pdf docker-pptx docker-serve serve
