# frozen_string_literal: true

name 'checksum_file'
maintainer 'OIT Systems Engineering'
maintainer_email 'ua-oit-se@alaska.edu'
license 'MIT'
description 'Writes the checksum of a source file or directory to a target file, often for implementing idempotence'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

git_url = 'https://github.com/ualaska-it/checksum_file'
source_url git_url if respond_to?(:source_url)
issues_url "#{git_url}/issues" if respond_to?(:issues_url)

version '1.0.3'

supports 'ubuntu', '>= 16.0'
supports 'debian', '>= 8.0'
supports 'redhat', '>= 6.0'
supports 'centos', '>= 6.0'
supports 'oracle', '>= 6.0'
supports 'fedora'
supports 'amazon'
supports 'suse'
# supports 'opensuse'

chef_version '>= 14.0' if respond_to?(:chef_version)
