# frozen_string_literal: true

# This module implements helpers that are used for tests
module ChecksumTest
  # This module exposes helpers to the client
  module Helper
    def path_to_data_directory
      return '/tmp/checksum_data'
    end

    def path_to_checksum_directory
      return '/tmp/checksum_checksum'
    end

    def path_to_test_directory
      return '/tmp/checksum_test'
    end

    def directories
      return [
        'data',
        'checksum',
        'test'
      ]
    end

    def filenames
      return [
        'file_1',
        'file_2'
      ]
    end

    # include_path, include_metadata
    def includes
      return [
        [true, true],
        [true, false]
      ]
    end

    def algorithms
      return [
        'md5',
        'sha1'
      ]
    end

    def other_group
      group =
        if node['platform_family'] == 'debian'
          'ssh'
        else
          'sshd'
        end
      return group
    end
  end
end

Chef::Provider.include(ChecksumTest::Helper)
Chef::Recipe.include(ChecksumTest::Helper)
Chef::Resource.include(ChecksumTest::Helper)
