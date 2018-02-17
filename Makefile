SUBDIRS = software-page-utils
AGENTSMITH_DOWNLOAD_URL=https://www.guengel.ch/myapps/agentsmith/downloads

FRAGASS = software-page-utils/bin/fragass
FRAGASS_TEMPLATE = -template templates/html_template.html

GENERATED_FRAGMENTS_DIR = work/generated_fragments
AGENTSMITH_SRC_DIR = work/agentsmith

HTML_TEMPLATE = templates/html_template.html

all: buildsubdirs buildhtml buildsitemap

clean: cleansubdirs cleanhtml cleansitemap
	rm -rf work
	rm -f untar-agentsmith work-dir

buildsubdirs:
	for d in $(SUBDIRS) ; do $(MAKE) -C $$d all ; done

buildhtml: public_html/index.html public_html/news.html public_html/downloads.html

buildsitemap: public_html/Sitemap.xml

public_html/Sitemap.xml:
	env BASE_URL=https://agentsmith.guengel.ch/ software-page-utils/sitemap.sh > $@

public_html/index.html: $(GENERATED_FRAGMENTS_DIR)/index.xml $(HTML_TEMPLATE)
	$(FRAGASS) $(FRAGASS_TEMPLATE) -fragment $< > $@

public_html/news.html: $(GENERATED_FRAGMENTS_DIR)/news.xml $(HTML_TEMPLATE)
	$(FRAGASS) $(FRAGASS_TEMPLATE) -fragment $< > $@

public_html/downloads.html: $(GENERATED_FRAGMENTS_DIR)/downloads.xml $(HTML_TEMPLATE)
	$(FRAGASS) $(FRAGASS_TEMPLATE) -fragment $< > $@

agentsmith.tar.xz:
	latest_release=`software-page-utils/bin/latestversion -package-name agentsmith` && curl -o agentsmith.tar.xz $(AGENTSMITH_DOWNLOAD_URL)/$$latest_release

untar-agentsmith: agentsmith.tar.xz work-dir
	gtar -C $(AGENTSMITH_SRC_DIR) --strip-components 1 -xf agentsmith.tar.xz
	@touch $@

$(AGENTSMITH_SRC_DIR)/NEWS: untar-agentsmith

$(GENERATED_FRAGMENTS_DIR)/news.xml: $(AGENTSMITH_SRC_DIR)/NEWS work-dir 
	software-page-utils/newsfragment.sh "Agentsmith News" $< $(GENERATED_FRAGMENTS_DIR)

$(GENERATED_FRAGMENTS_DIR)/index.xml: templates/index.tmpl work-dir
	software-page-utils/bin/indexfrag -package-name "agentsmith" -page-title "Agentsmith" > $@

$(GENERATED_FRAGMENTS_DIR)/downloads.xml: templates/downloads.tmpl work-dir
	software-page-utils/bin/downloadfrag -page-title "Agentsmith Downloads" > $@

work-dir:
	mkdir -p $(AGENTSMITH_SRC_DIR)
	mkdir -p $(GENERATED_FRAGMENTS_DIR)
	mkdir -p work/tmp
	@touch $@

cleansubdirs:
	for d in $(SUBDIRS) ; do  $(MAKE) -C $$d clean ; done

cleanhtml:
	rm -f public_html/*.html

cleansitemap:
	rm -f public_html/Sitemap.xml

.PHONY: buildsubdirs
