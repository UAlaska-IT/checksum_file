# frozen_string_literal: true

name 'checksum_file'
maintainer 'OIT Systems Engineering'
maintainer_email 'ua-oit-se@alaska.edu'
license 'MIT'
description 'Writes the checksum of a source file or directory to a target file, often for implementing idempotence'

git_url = 'https://github.com/ualaska-it/checksum_file'
source_url git_url
issues_url "#{git_url}/issues"

version '1.0.4'

supports 'ubuntu', '>= 16.0'
supports 'debian', '>= 8.0'
supports 'redhat', '>= 6.0'
supports 'centos', '>= 6.0'
supports 'oracle', '>= 6.0'
# supports 'fedora'
supports 'amazon'
supports 'suse'
# supports 'opensuse'
# supports 'windows', '>= 6.3' # Windows 2012R2, see https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions

chef_version '>= 14.0'
