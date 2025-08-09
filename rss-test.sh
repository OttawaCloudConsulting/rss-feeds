#!/bin/bash
#
# RSS Feed Validator Script
# Tests all RSS feed URLs from an OPML file for availability and validity
# Usage: bash rss-test.sh [opml-file]
#   If no file specified, will auto-detect single *.opml file in current directory

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
OPML_FILE=""
LOG_FILE=""
TEMP_URLS=""
TOTAL_FEEDS=0
VALID_FEEDS=0
INVALID_FEEDS=0
TIMEOUT_FEEDS=0

#######################################
# Display usage information
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes usage information to stdout
#######################################
usage() {
  echo "Usage: $0 [opml-file]"
  echo ""
  echo "Arguments:"
  echo "  opml-file    Optional path to OPML file to test"
  echo ""
  echo "If no file is specified, the script will:"
  echo "  - Auto-detect if there's exactly one *.opml file in the current directory"
  echo "  - Use that file for testing"
  echo "  - Exit with error if multiple *.opml files are found"
  echo ""
  echo "Examples:"
  echo "  $0 AllFeeds.opml         # Test specific file"
  echo "  $0                       # Auto-detect single .opml file"
}

#######################################
# Determine which OPML file to use based on arguments
# Globals:
#   OPML_FILE
# Arguments:
#   Command line arguments ($@)
# Outputs:
#   Sets OPML_FILE variable or exits with error
#######################################
determine_opml_file() {
  if [[ $# -eq 0 ]]; then
    # No arguments provided, try to auto-detect
    local opml_files=(*.opml)
    
    # Check if any .opml files exist
    if [[ ${#opml_files[@]} -eq 0 || ! -f "${opml_files[0]}" ]]; then
      echo -e "${RED}Error: No OPML files found in current directory${NC}"
      echo ""
      usage
      exit 1
    elif [[ ${#opml_files[@]} -eq 1 ]]; then
      # Exactly one .opml file found
      OPML_FILE="${opml_files[0]}"
      echo "Auto-detected OPML file: ${OPML_FILE}"
    else
      # Multiple .opml files found
      echo -e "${RED}Error: Multiple OPML files found in current directory:${NC}"
      for file in "${opml_files[@]}"; do
        echo "  - ${file}"
      done
      echo ""
      echo "Please specify which file to test:"
      echo "  $0 <filename>"
      echo ""
      usage
      exit 1
    fi
  elif [[ $# -eq 1 ]]; then
    # Check for help option
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
      usage
      exit 0
    fi
    
    # File specified as argument
    OPML_FILE="$1"
  else
    # Too many arguments
    echo -e "${RED}Error: Too many arguments${NC}"
    echo ""
    usage
    exit 1
  fi
}

#######################################
# Set up file paths and variables
# Globals:
#   LOG_FILE, TEMP_URLS, OPML_FILE
# Arguments:
#   None
# Outputs:
#   Sets global variables for file paths
#######################################
setup_file_paths() {
  if [[ -n "${OPML_FILE}" ]]; then
    local opml_basename
    opml_basename=$(basename "${OPML_FILE}" .opml)
    LOG_FILE="${opml_basename}_test_results.log"
    TEMP_URLS="/tmp/rss_urls_${opml_basename}.txt"
  else
    LOG_FILE="rss_test_results.log"
    TEMP_URLS="/tmp/rss_urls.txt"
  fi
}

#######################################
# Test a single RSS feed for validity
# Globals:
#   VALID_FEEDS, INVALID_FEEDS, TIMEOUT_FEEDS, TOTAL_FEEDS, LOG_FILE
#   GREEN, RED, NC
# Arguments:
#   $1 - URL to test
#   $2 - Name of the feed
# Outputs:
#   Writes test results to stdout and log file
#######################################
test_feed() {
  local url="$1"
  local name="$2"
  local response
  local status_code
  local content_type
  local time_total
  
  # Test HTTP status and content type
  if response=$(curl -s -L -w "%{http_code}|%{content_type}|%{time_total}" -m 10 "${url}" -o /dev/null 2>/dev/null); then
    IFS='|' read -r status_code content_type time_total <<< "${response}"
    
    # Check if status code is successful (2xx)
    if [[ "${status_code}" =~ ^2[0-9][0-9]$ ]]; then
      # Check if content type suggests RSS/XML
      if [[ "${content_type}" =~ (xml|rss|atom) ]]; then
        echo -e "${GREEN}✓${NC} ${name}"
        echo -e "  URL: ${url}"
        echo -e "  Status: ${status_code} | Type: ${content_type} | Time: ${time_total}s"
        echo ""
        
        # Log success
        {
          echo "✓ VALID: ${name}"
          echo "  URL: ${url}"
          echo "  Status: ${status_code} | Type: ${content_type} | Time: ${time_total}s"
          echo ""
        } >> "${LOG_FILE}"
        
        VALID_FEEDS=$((VALID_FEEDS + 1))
      else
        echo -e "${RED}⚠${NC} ${name}"
        echo -e "  URL: ${url}"
        echo -e "  Status: ${status_code} | Type: ${content_type} (Not XML/RSS)"
        echo ""
        
        # Log warning
        {
          echo "⚠ WARNING: ${name}"
          echo "  URL: ${url}"
          echo "  Status: ${status_code} | Type: ${content_type} (Not XML/RSS)"
          echo ""
        } >> "${LOG_FILE}"
        
        INVALID_FEEDS=$((INVALID_FEEDS + 1))
      fi
    else
      echo -e "${RED}✗${NC} ${name}"
      echo -e "  URL: ${url}"
      echo -e "  Status: ${status_code} | Type: ${content_type}"
      echo ""
      
      # Log error
      {
        echo "✗ ERROR: ${name}"
        echo "  URL: ${url}"
        echo "  Status: ${status_code} | Type: ${content_type}"
        echo ""
      } >> "${LOG_FILE}"
      
      INVALID_FEEDS=$((INVALID_FEEDS + 1))
    fi
  else
    echo -e "${RED}✗${NC} ${name}"
    echo -e "  URL: ${url}"
    echo -e "  Error: Timeout or connection failed"
    echo ""
    
    # Log timeout
    {
      echo "✗ TIMEOUT: ${name}"
      echo "  URL: ${url}"
      echo "  Error: Timeout or connection failed"
      echo ""
    } >> "${LOG_FILE}"
    
    TIMEOUT_FEEDS=$((TIMEOUT_FEEDS + 1))
  fi
  
  TOTAL_FEEDS=$((TOTAL_FEEDS + 1))
}

#######################################
# Main function to run the RSS feed validator
# Globals:
#   All global variables
# Arguments:
#   Command line arguments ($@)
# Outputs:
#   Test results and summary
#######################################
main() {
  # Determine which OPML file to use
  determine_opml_file "$@"
  
  # Set up file paths
  setup_file_paths
  
  echo -e "${BLUE}RSS Feed Validator${NC}"
  echo "===================="
  echo "Testing feeds from: ${OPML_FILE}"
  echo "Results will be logged to: ${LOG_FILE}"
  echo ""
  
  # Check if OPML file exists
  if [[ ! -f "${OPML_FILE}" ]]; then
    echo -e "${RED}Error: OPML file '${OPML_FILE}' not found!${NC}"
    echo ""
    usage
    exit 1
  fi
  
  # Extract URLs and names from OPML file
  echo "Extracting URLs from OPML file..."
  perl -0777 -ne '
      while (/<outline\s+text="([^"]*)"[^>]*xmlUrl="([^"]*)"[^>]*\/>/gs) {
          print "$2|$1\n";
      }
  ' "${OPML_FILE}" > "${TEMP_URLS}.pairs"
  
  # Start logging
  echo "RSS Feed Validation Results - $(date)" > "${LOG_FILE}"
  echo "=============================================" >> "${LOG_FILE}"
  echo "" >> "${LOG_FILE}"
  
  # Test each feed
  echo "Testing feeds..."
  echo ""
  
  local url name
  while IFS='|' read -r url name; do
    if [[ -n "${url}" ]]; then
      if [[ -z "${name}" ]]; then
        name="Unknown Feed"
      fi
      
      test_feed "${url}" "${name}"
      
      # Small delay to avoid overwhelming servers
      sleep 0.5
    fi
  done < "${TEMP_URLS}.pairs"
  
  # Summary
  echo "============================================="
  echo -e "${BLUE}TEST SUMMARY${NC}"
  echo "============================================="
  echo "Total feeds tested: ${TOTAL_FEEDS}"
  echo -e "Valid feeds: ${GREEN}${VALID_FEEDS}${NC}"
  echo -e "Invalid feeds: ${RED}${INVALID_FEEDS}${NC}"
  echo -e "Timeout/Failed: ${RED}${TIMEOUT_FEEDS}${NC}"
  echo ""
  
  # Calculate percentage
  local success_rate
  if [[ ${TOTAL_FEEDS} -gt 0 ]]; then
    success_rate=$(( (VALID_FEEDS * 100) / TOTAL_FEEDS ))
    echo "Success rate: ${success_rate}%"
  fi
  
  # Log summary
  {
    echo ""
    echo "============================================="
    echo "TEST SUMMARY"
    echo "============================================="
    echo "Total feeds tested: ${TOTAL_FEEDS}"
    echo "Valid feeds: ${VALID_FEEDS}"
    echo "Invalid feeds: ${INVALID_FEEDS}"
    echo "Timeout/Failed: ${TIMEOUT_FEEDS}"
    if [[ ${TOTAL_FEEDS} -gt 0 ]]; then
      echo "Success rate: ${success_rate}%"
    fi
    echo "Test completed at: $(date)"
  } >> "${LOG_FILE}"
  
  # Cleanup
  rm -f "${TEMP_URLS}" "${TEMP_URLS}.pairs"
  
  echo ""
  echo "Results saved to: ${LOG_FILE}"
  
  # Exit with error code if there were failures
  if [[ ${INVALID_FEEDS} -gt 0 || ${TIMEOUT_FEEDS} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
}

# Run main function with all arguments
main "$@"
