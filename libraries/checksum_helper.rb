# frozen_string_literal: true

# This module implements helpers that are used for checksum resources
module ChecksumFile
  # This module implements helpers that are used for checksum resources
  module Helper
  end
end

Chef::Provider.include(ChecksumFile::Helper)
Chef::Recipe.include(ChecksumFile::Helper)
Chef::Resource.include(ChecksumFile::Helper)
