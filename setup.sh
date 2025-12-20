#!/bin/bash

###############################################################################
# BizFlow Setup & Maintenance Script
# 
# Usage:
#   bash setup.sh                    - Show menu
#   bash setup.sh init-db            - Initialize database
#   bash setup.sh build              - Build project
#   bash setup.sh run                - Run application
#   bash setup.sh clean              - Clean build
#   bash setup.sh test-login         - Test login API
#   bash setup.sh full-setup         - Do everything (db + build + run)
#   bash setup.sh docker-up          - Start Docker Compose
#   bash setup.sh docker-down        - Stop Docker Compose
#
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MYSQL_HOST="localhost"
MYSQL_USER="root"
MYSQL_PASSWORD="root"
MYSQL_PORT="3306"
APP_PORT="8080"
APP_NAME="BizFlow"

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

check_command() {
    if command -v $1 &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is NOT installed"
        return 1
    fi
}

wait_for_mysql() {
    print_info "Waiting for MySQL to be ready..."
    for i in {1..30}; do
        if mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -P "$MYSQL_PORT" -e "SELECT 1" &> /dev/null; then
            print_success "MySQL is ready!"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    print_error "MySQL is not responding after 30 seconds"
    return 1
}

###############################################################################
# Main Functions
###############################################################################

init_database() {
    print_header "Initializing Database"
    
    check_command mysql || {
        print_error "MySQL client not found. Please install MySQL."
        return 1
    }
    
    wait_for_mysql || return 1
    
    print_info "Running init.sql..."
    if mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -P "$MYSQL_PORT" < data/init.sql; then
        print_success "Database initialized successfully!"
        return 0
    else
        print_error "Failed to initialize database"
        return 1
    fi
}

build_project() {
    print_header "Building Project with Maven"
    
    check_command mvn || {
        print_error "Maven not found. Please install Maven."
        return 1
    }
    
    print_info "Running: mvn clean install -DskipTests"
    if mvn clean install -DskipTests; then
        print_success "Project built successfully!"
        return 0
    else
        print_error "Build failed"
        return 1
    fi
}

run_application() {
    print_header "Running BizFlow Application"
    
    if [ ! -f "target/bizflow-1.0.0.jar" ]; then
        print_error "JAR file not found. Please run 'build' first."
        return 1
    fi
    
    print_info "Starting application on port $APP_PORT..."
    print_info "Open browser: http://localhost:$APP_PORT"
    print_info "Username: admin | Password: admin123"
    print_info ""
    print_info "Press Ctrl+C to stop"
    
    java -jar target/bizflow-1.0.0.jar
}

clean_project() {
    print_header "Cleaning Build Artifacts"
    
    check_command mvn || {
        print_error "Maven not found."
        return 1
    }
    
    print_info "Removing target directory..."
    mvn clean
    
    print_success "Project cleaned!"
}

test_login_api() {
    print_header "Testing Login API"
    
    check_command curl || {
        print_error "curl not found. Please install curl."
        return 1
    }
    
    API_URL="http://localhost:$APP_PORT/api/auth/login"
    
    print_info "Checking if app is running on port $APP_PORT..."
    if ! curl -s http://localhost:$APP_PORT/api/auth/health &> /dev/null; then
        print_error "Application is not running on port $APP_PORT"
        print_info "Start the app first with: bash setup.sh run"
        return 1
    fi
    
    print_success "Application is running!"
    
    # Test 1: Valid credentials (admin)
    echo ""
    print_info "Test 1: Login with admin/admin123"
    curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d '{"username":"admin","password":"admin123"}' | \
        if command -v jq &> /dev/null; then jq .; else cat; fi
    
    # Test 2: Valid credentials (test)
    echo ""
    echo ""
    print_info "Test 2: Login with test/test123"
    curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d '{"username":"test","password":"test123"}' | \
        if command -v jq &> /dev/null; then jq .; else cat; fi
    
    # Test 3: Invalid credentials
    echo ""
    echo ""
    print_info "Test 3: Login with invalid credentials (admin/wrong)"
    curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d '{"username":"admin","password":"wrong"}' | \
        if command -v jq &> /dev/null; then jq .; else cat; fi
    
    echo ""
    echo ""
    print_success "Tests completed!"
}

full_setup() {
    print_header "FULL SETUP: Database → Build → Run"
    
    print_info "Step 1/3: Initializing database..."
    init_database || return 1
    
    print_info "Step 2/3: Building project..."
    build_project || return 1
    
    print_info "Step 3/3: Starting application..."
    echo ""
    run_application
}

docker_up() {
    print_header "Starting Docker Compose"
    
    check_command docker-compose || {
        print_error "Docker Compose not found. Please install Docker."
        return 1
    }
    
    print_info "Building Docker images..."
    docker-compose build
    
    print_info "Starting containers..."
    docker-compose up -d
    
    print_success "Docker containers started!"
    print_info "View logs with: docker-compose logs -f app"
    print_info "Stop with: docker-compose down"
    
    sleep 3
    docker-compose logs app | tail -20
}

docker_down() {
    print_header "Stopping Docker Compose"
    
    check_command docker-compose || {
        print_error "Docker Compose not found."
        return 1
    }
    
    docker-compose down
    print_success "Docker containers stopped!"
}

show_menu() {
    print_header "BizFlow Setup & Maintenance"
    
    echo "Available commands:"
    echo ""
    echo -e "${GREEN}Setup Commands:${NC}"
    echo "  init-db        Initialize MySQL database"
    echo "  build          Build project with Maven"
    echo "  run            Run application (java -jar)"
    echo "  full-setup     Do everything (db + build + run)"
    echo ""
    echo -e "${GREEN}Development Commands:${NC}"
    echo "  clean          Clean Maven build artifacts"
    echo "  test-login     Test login API endpoints"
    echo ""
    echo -e "${GREEN}Docker Commands:${NC}"
    echo "  docker-up      Start Docker Compose (MySQL + App)"
    echo "  docker-down    Stop Docker Compose"
    echo ""
    echo -e "${GREEN}Other:${NC}"
    echo "  help           Show this menu"
    echo ""
}

###############################################################################
# Main Entry Point
###############################################################################

main() {
    case "${1:-help}" in
        init-db)
            init_database
            ;;
        build)
            build_project
            ;;
        run)
            run_application
            ;;
        clean)
            clean_project
            ;;
        test-login)
            test_login_api
            ;;
        full-setup)
            full_setup
            ;;
        docker-up)
            docker_up
            ;;
        docker-down)
            docker_down
            ;;
        help|"")
            show_menu
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_menu
            exit 1
            ;;
    esac
}

# Run main function with arguments
main "$@"
