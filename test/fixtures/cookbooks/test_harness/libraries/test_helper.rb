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
      return 'ssh' if node['platform_family'] == 'debian'

      'sshd'
    end

    def create_directory
      bash 'reset' do
        code "rm -rf #{path_to_data_directory}"
      end
      directory path_to_data_directory
      filenames.each do |filename|
        path = File.join(path_to_data_directory, filename)
        file path do
          content filename
        end
      end
    end

    def reset_directory(source_path, target_path, include, algorithm)
      create_directory
      checksum_file 'reset' do
        source_path source_path
        target_path target_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end
    end
  end
end

Chef::Provider.include(ChecksumTest::Helper)
Chef::Recipe.include(ChecksumTest::Helper)
Chef::Resource.include(ChecksumTest::Helper)
