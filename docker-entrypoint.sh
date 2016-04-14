#!/bin/bash

set -e

# Add kibana as command if needed
if [[ "$1" == -* ]]; then
	set -- kibana "$@"
fi

# Run as user "kibana" if the command is "kibana"
if [ "$1" = 'kibana' ]; then
	if [ "$ELASTICSEARCH_URL" -o "$ELASTICSEARCH_PORT_9200_TCP" ]; then
		: ${ELASTICSEARCH_URL:='http://elasticsearch:9200'}
		sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 '$ELASTICSEARCH_URL'!" /opt/kibana/config/kibana.yml
	else
		echo >&2 'warning: missing ELASTICSEARCH_PORT_9200_TCP or ELASTICSEARCH_URL'
		echo >&2 '  Did you forget to --link some-elasticsearch:elasticsearch'
		echo >&2 '  or -e ELASTICSEARCH_URL=http://some-elasticsearch:9200 ?'
		echo >&2
	fi

    if [ "$ELASTICSEARCH_USERNAME" ]; then
		sed -ri "s!^(\#\s*)?(elasticsearch\.username:).*!\2 '$ELASTICSEARCH_USERNAME'!" /opt/kibana/config/kibana.yml
	fi

    if [ "$ELASTICSEARCH_PASSWORD" ]; then
		sed -ri "s!^(\#\s*)?(elasticsearch\.password:).*!\2 '$ELASTICSEARCH_PASSWORD'!" /opt/kibana/config/kibana.yml
	fi

    if [ "$KIBANA_BASEPATH" ]; then
		sed -ri "s!^(\#\s*)?(server\.basePath:).*!\2 '$KIBANA_BASEPATH'!" /opt/kibana/config/kibana.yml
	fi

	set -- gosu kibana "$@"
fi

exec "$@"
