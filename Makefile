VERSION?=0.0.0

build:
	gem build logstash-input-honeydb \
	&& logstash-plugin install logstash-input-honeydb-$(VERSION).gem

run:
	logstash -f logstash-input-honeydb.conf

install:
	logstash-plugin install logstash-input-honeydb

remove:
	logstash-plugin remove logstash-input-honeydb

publish:
	gem push logstash-input-honeydb-$(VERSION).gem

lint:
	gem instal ruby-lint
	ruby-lint lib/logstash/inputs/honeydb.rb

clean:
	rm logstash-input-honeydb-*.gem
