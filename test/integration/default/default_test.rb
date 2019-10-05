# frozen_string_literal: true

path_to_data_directory = '/tmp/checksum_data'
path_to_checksum_directory = '/tmp/checksum_checksum'
path_to_test_directory = '/tmp/checksum_test'

filenames = [
  'file_1',
  'file_2'
]

paths = [
  path_to_data_directory
]

filenames.each do |filename|
  paths.append(File.join(path_to_data_directory, filename))
end

# Check that we at least have base paths correct
paths.each do |path|
  describe file path do
    it { should exist }
  end
end

# include_path, include_metadata
includes = [
  [true, true],
  [true, false]
]

algorithms = [
  'md5',
  'sha1'
]

include_meta_regex = /(?:(?:(?:true|false)_true)|checksum_data)/

# Test files themselves
includes.each do |include|
  algorithms.each do |algorithm|
    paths.each do |path|
      base_name = "#{File.basename(path)}_#{include[0]}_#{include[1]}_#{algorithm}"

      # Check checksum itself
      describe file File.join(path_to_checksum_directory, base_name) do
        it { should exist }
        it { should be_file }
        it { should be_mode 0o644 }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
      end

      # Check first creation
      describe file File.join(path_to_test_directory, "#{base_name}_create") do
        it { should exist }
        it { should be_file }
        it { should be_mode 0o644 }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
      end

      # Check no change
      describe file File.join(path_to_test_directory, "#{base_name}_none") do
        it { should_not exist }
      end

      # Check content change
      describe file File.join(path_to_test_directory, "#{base_name}_content") do
        it { should exist }
        it { should be_file }
        it { should be_mode 0o644 }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
      end

      # Check modified time change
      describe file File.join(path_to_test_directory, "#{base_name}_mtime") do
        if base_name.match?(include_meta_regex)
          it { should exist }
          it { should be_file }
          it { should be_mode 0o644 }
          it { should be_owned_by 'root' }
          it { should be_grouped_into 'root' }
        else
          it { should_not exist }
        end
      end

      # Check permissions change
      describe file File.join(path_to_test_directory, "#{base_name}_mode") do
        if base_name.match?(include_meta_regex)
          it { should exist }
          it { should be_file }
          it { should be_mode 0o644 }
          it { should be_owned_by 'root' }
          it { should be_grouped_into 'root' }
        else
          it { should_not exist }
        end
      end

      # Check group change
      describe file File.join(path_to_test_directory, "#{base_name}_group") do
        if base_name.match?(include_meta_regex)
          it { should exist }
          it { should be_file }
          it { should be_mode 0o644 }
          it { should be_owned_by 'root' }
          it { should be_grouped_into 'root' }
        else
          it { should_not exist }
        end
      end
    end
  end
end

describe user('bud') do
  it { should exist }
  its('group') { should eq 'bud' }
  its('groups') { should eq ['bud'] }
  its('home') { should eq '/home/bud' }
  its('shell') { should eq '/bin/bash' }
end

# Test directory content
includes.each do |include|
  algorithms.each do |algorithm|
    base_name = "#{include[0]}_#{include[1]}_#{algorithm}"

    # Check checksum itself
    describe file File.join(path_to_checksum_directory, base_name) do
      it { should exist }
      it { should be_file }
      it { should be_mode 0o701 }
      it { should be_owned_by 'bud' }
      it { should be_grouped_into 'bud' }
    end

    # Check first creation
    describe file File.join(path_to_test_directory, "#{base_name}_create") do
      it { should exist }
      it { should be_file }
      it { should be_mode 0o644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    # Check no change
    describe file File.join(path_to_test_directory, "#{base_name}_none") do
      it { should_not exist }
    end

    # Check directory modified time change
    describe file File.join(path_to_test_directory, "#{base_name}_dir_mtime") do
      it { should exist }
      it { should be_file }
      it { should be_mode 0o644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    # Check directory permissions change
    describe file File.join(path_to_test_directory, "#{base_name}_dir_mode") do
      it { should exist }
      it { should be_file }
      it { should be_mode 0o644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    # Check directory group change
    describe file File.join(path_to_test_directory, "#{base_name}_dir_group") do
      it { should exist }
      it { should be_file }
      it { should be_mode 0o644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    # Check content change
    describe file File.join(path_to_test_directory, "#{base_name}_content") do
      it { should exist }
      it { should be_file }
      it { should be_mode 0o644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    # Check modified time change
    describe file File.join(path_to_test_directory, "#{base_name}_mtime") do
      it { should exist }
      it { should be_file }
      it { should be_mode 0o644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    # Check permissions change
    describe file File.join(path_to_test_directory, "#{base_name}_mode") do
      it { should exist }
      it { should be_file }
      it { should be_mode 0o644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    # Check group change
    describe file File.join(path_to_test_directory, "#{base_name}_group") do
      it { should exist }
      it { should be_file }
      it { should be_mode 0o644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
