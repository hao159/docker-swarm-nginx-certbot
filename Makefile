# Makefile for managing Nginx and Certbot configurations and certificates

DOMAIN ?= example.com

.PHONY: help add-domain reload-nginx test-config

# show help command Makefile
help:
	@echo "Usage:"
	@echo "  make add-domain DOMAIN=<domain-name>  -- Add a new domain and configure SSL."
	@echo "  make reload-nginx                   -- Reload Nginx to apply new configurations."
	@echo "  make test-config                    -- Test Nginx configuration for errors."

# add new domain and config SSL
add-domain:
	@echo "Adding new domain: $(DOMAIN)"
	@bash add-domain.sh $(DOMAIN)

# Reload service Nginx
reload-nginx:
	@echo "Reloading Nginx configuration"
	@docker exec nginx nginx -s reload

# test config Nginx
test-config:
	@echo "Testing Nginx configuration"
	@docker exec nginx nginx -t


# Ex: make add-domain DOMAIN=yourdomain.com
