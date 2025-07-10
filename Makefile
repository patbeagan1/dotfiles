# libbeagan Makefile
# Common tasks for managing the dotfiles repository

.PHONY: help install test clean lint docs update-deps

# Default target
help:
	@echo "libbeagan - Available commands:"
	@echo ""
	@echo "Installation:"
	@echo "  install     - Install libbeagan (requires LIBBEAGAN_HOME to be set)"
	@echo "  install-local - Install for current user (sets LIBBEAGAN_HOME to ~/libbeagan)"
	@echo ""
	@echo "Testing:"
	@echo "  test        - Run quick tests"
	@echo "  test-full   - Run full test suite"
	@echo "  test-verbose - Run tests with verbose output"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean       - Remove temporary files and test artifacts"
	@echo "  lint        - Check script syntax and permissions"
	@echo "  fix-perms   - Fix script permissions"
	@echo "  update-deps - Update dependency information"
	@echo ""
	@echo "Documentation:"
	@echo "  docs        - Generate documentation"
	@echo "  stats       - Show repository statistics"
	@echo ""
	@echo "Development:"
	@echo "  new-script  - Create a new script from template"
	@echo "  new-alias   - Create a new alias file"

# Installation targets
install:
	@if [ -z "$$LIBBEAGAN_HOME" ]; then \
		echo "Error: LIBBEAGAN_HOME environment variable is not set"; \
		echo "Please set it to the path where you want to install libbeagan"; \
		exit 1; \
	fi
	@echo "Installing libbeagan to $$LIBBEAGAN_HOME..."
	@if [ ! -d "$$LIBBEAGAN_HOME" ]; then \
		mkdir -p "$$LIBBEAGAN_HOME"; \
	fi
	@cp -r . "$$LIBBEAGAN_HOME/"
	@chmod +x "$$LIBBEAGAN_HOME/install.zsh"
	@echo "✅ Installation complete!"
	@echo "Add the following to your ~/.zshrc:"
	@echo "export LIBBEAGAN_HOME=\"$$LIBBEAGAN_HOME\""
	@echo "source \"$$LIBBEAGAN_HOME/install.zsh\""

install-local:
	@echo "Installing libbeagan locally..."
	@$(MAKE) LIBBEAGAN_HOME=$$HOME/libbeagan install

# Testing targets
test:
	@echo "Running quick tests..."
	@if [ -n "$$LIBBEAGAN_HOME" ] && [ -f "$$LIBBEAGAN_HOME/scripts/util/test-libbeagan.sh" ]; then \
		"$$LIBBEAGAN_HOME/scripts/util/test-libbeagan.sh" --quick; \
	elif [ -f "./scripts/util/test-libbeagan.sh" ]; then \
		./scripts/util/test-libbeagan.sh --quick; \
	else \
		echo "Test script not found. Please install libbeagan first."; \
		exit 1; \
	fi

test-full:
	@echo "Running full test suite..."
	@if [ -n "$$LIBBEAGAN_HOME" ] && [ -f "$$LIBBEAGAN_HOME/scripts/util/test-libbeagan.sh" ]; then \
		"$$LIBBEAGAN_HOME/scripts/util/test-libbeagan.sh" --full; \
	elif [ -f "./scripts/util/test-libbeagan.sh" ]; then \
		./scripts/util/test-libbeagan.sh --full; \
	else \
		echo "Test script not found. Please install libbeagan first."; \
		exit 1; \
	fi

test-verbose:
	@echo "Running tests with verbose output..."
	@if [ -n "$$LIBBEAGAN_HOME" ] && [ -f "$$LIBBEAGAN_HOME/scripts/util/test-libbeagan.sh" ]; then \
		"$$LIBBEAGAN_HOME/scripts/util/test-libbeagan.sh" --full --verbose; \
	elif [ -f "./scripts/util/test-libbeagan.sh" ]; then \
		./scripts/util/test-libbeagan.sh --full --verbose; \
	else \
		echo "Test script not found. Please install libbeagan first."; \
		exit 1; \
	fi

# Maintenance targets
clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.bak" -delete
	@find . -name "*.tmp" -delete
	@find . -name ".DS_Store" -delete
	@rm -rf /tmp/libbeagan-test-*
	@echo "✅ Cleanup complete!"

lint:
	@echo "Checking script syntax and permissions..."
	@find scripts/ -name "*.sh" -type f -exec sh -n {} \; -print
	@find scripts/ -name "*.zsh" -type f -exec zsh -n {} \; -print
	@echo "✅ Syntax check complete!"

fix-perms:
	@echo "Fixing script permissions..."
	@find scripts/ -name "*.sh" -type f -exec chmod +x {} \;
	@find scripts/ -name "*.zsh" -type f -exec chmod +x {} \;
	@find aliases/ -name "*.zsh" -type f -exec chmod +x {} \;
	@chmod +x install.zsh
	@chmod +x dependencies.sh
	@echo "✅ Permissions fixed!"

update-deps:
	@echo "Updating dependency information..."
	@if [ -f "./scripts/util/check_program.sh" ]; then \
		./scripts/util/check_program.sh > dependencies-check.txt; \
		echo "✅ Dependencies checked and saved to dependencies-check.txt"; \
	else \
		echo "Dependency check script not found"; \
	fi

# Documentation targets
docs:
	@echo "Generating documentation..."
	@echo "# libbeagan Scripts Reference" > docs/scripts-reference.md
	@echo "" >> docs/scripts-reference.md
	@echo "Generated on $(shell date)" >> docs/scripts-reference.md
	@echo "" >> docs/scripts-reference.md
	@for dir in scripts/*/; do \
		if [ -d "$$dir" ]; then \
			dirname=$$(basename "$$dir"); \
			echo "## $$dirname" >> docs/scripts-reference.md; \
			echo "" >> docs/scripts-reference.md; \
			for script in "$$dir"*.sh "$$dir"*.py "$$dir"*.js "$$dir"*.ts; do \
				if [ -f "$$script" ]; then \
					scriptname=$$(basename "$$script"); \
					echo "- $$scriptname" >> docs/scripts-reference.md; \
				fi; \
			done; \
			echo "" >> docs/scripts-reference.md; \
		fi; \
	done
	@echo "✅ Documentation generated in docs/scripts-reference.md"

stats:
	@echo "Repository Statistics:"
	@echo "======================"
	@echo "Scripts by category:"
	@for dir in scripts/*/; do \
		if [ -d "$$dir" ]; then \
			dirname=$$(basename "$$dir"); \
			count=$$(find "$$dir" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.lua" -o -name "*.exs" \) | wc -l); \
			echo "  $$dirname: $$count scripts"; \
		fi; \
	done
	@echo ""
	@echo "Alias files:"
	@alias_count=$$(find aliases/ -name "*.zsh" | wc -l); \
	echo "  Total: $$alias_count alias files"
	@echo ""
	@echo "Configuration files:"
	@config_count=$$(find configs/ -name "*.zsh" | wc -l); \
	echo "  Total: $$config_count config files"

# Development targets
new-script:
	@if [ -z "$(NAME)" ]; then \
		echo "Error: Please specify a script name with NAME=<name>"; \
		echo "Example: make new-script NAME=my-utility"; \
		exit 1; \
	fi
	@if [ -z "$(CATEGORY)" ]; then \
		echo "Error: Please specify a category with CATEGORY=<category>"; \
		echo "Example: make new-script NAME=my-utility CATEGORY=util"; \
		exit 1; \
	fi
	@echo "Creating new script: scripts/$(CATEGORY)/$(NAME).sh"
	@mkdir -p "scripts/$(CATEGORY)"
	@cp templates/script_template.sh "scripts/$(CATEGORY)/$(NAME).sh"
	@chmod +x "scripts/$(CATEGORY)/$(NAME).sh"
	@echo "✅ Script created! Edit scripts/$(CATEGORY)/$(NAME).sh to add your functionality."

new-alias:
	@if [ -z "$(NAME)" ]; then \
		echo "Error: Please specify an alias name with NAME=<name>"; \
		echo "Example: make new-alias NAME=my-tools"; \
		exit 1; \
	fi
	@echo "Creating new alias file: aliases/alias_$(NAME).zsh"
	@echo "# Aliases for $(NAME)" > "aliases/alias_$(NAME).zsh"
	@echo "# (c) $(shell date +%Y) Pat Beagan: MIT License" >> "aliases/alias_$(NAME).zsh"
	@echo "" >> "aliases/alias_$(NAME).zsh"
	@echo "# Add your aliases here:" >> "aliases/alias_$(NAME).zsh"
	@echo "# alias example='echo \"This is an example\"'" >> "aliases/alias_$(NAME).zsh"
	@chmod +x "aliases/alias_$(NAME).zsh"
	@echo "✅ Alias file created! Edit aliases/alias_$(NAME).zsh to add your aliases." 